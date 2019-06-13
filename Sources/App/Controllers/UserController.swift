//
//  UserController.swift
//  App
//
//  Created by Zach Eriksen on 3/21/19.
//

import Vapor
import FluentSQL
import Crypto
import Authentication

class UserController: RouteCollection {
    func boot(router: Router) throws {
//        router.get("register", use: registerHandler)
//        router.get("login", use: loginHandler)
//
        router.post("register", use: register)
        
        let authSessionRouter = router.grouped(User.authSessionsMiddleware())
        authSessionRouter.post("login", use: login)
        
        let protectedRouter = authSessionRouter.grouped(RedirectMiddleware<User>(path: "/login"))
        
        router.get(use: indexHandler)
        
        protectedRouter.get("cards", use: getCards)
        protectedRouter.post("cards", use: addCard)
        protectedRouter.post("cards", Card.parameter, "update", use: updateCard)
        protectedRouter.post("cards", Card.parameter, "delete", use: deleteCard)
        
        router.get("logout", use: logout)
    }
    
    // MARK: View Handlers
    
    func indexHandler(_ req: Request) throws -> Future<View> {
//        let user = try req.requireAuthenticated(User.self)
//        let context = LeafContext(title: "Home", user: user)
        return try req.view().render("Children/index")
    }
    
    func loginHandler(_ req: Request) throws -> Future<View> {
        let context = LeafContext(title: "Login", user: nil)
        return try req.view().render("Children/login", context)
    }
    
    func registerHandler(_ req: Request) throws -> Future<View> {
        let context = LeafContext(title: "Register", user: nil)
        return try req.view().render("Children/register", context)
    }
    
    // MARK: Request Handlers
    
    func register(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(User.self).flatMap { user in
            return User.query(on: req).filter(\User.username == user.username).first().flatMap { result in
                if let _ = result {
                    return Future.map(on: req) {
                        return .badRequest
                    }
                }
                user.password = try BCryptDigest().hash(user.password)
                
                return user.save(on: req).map { _ in
                    return .accepted
                }
            }
        }
    }
    
    func login(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(User.self).flatMap { user in
            return User.authenticate(
                username: user.username,
                password: user.password,
                using: BCryptDigest(),
                on: req
                ).map { user in
                    guard let user = user else {
                        return .badRequest
                    }
                    
                    try req.authenticateSession(user)
                    return .accepted
            }
        }
    }
    
    func addCard(_ req: Request) throws -> Future<Card> {
        _ = try req.requireAuthenticated(User.self)
        return try req.content.decode(Card.self).flatMap { newCard in
            return newCard.save(on: req)
        }
    }
    
    func deleteCard(_ req: Request) throws -> Future<HTTPStatus> {
        _ = try req.requireAuthenticated(User.self)
        return try req.content.decode(Card.self)
            .flatMap { newCard in
                return newCard.delete(on: req)
                    .flatMap {
                        Future.map(on: req) { return .noContent }
                }
        }
    }
    
    func updateCard(_ req: Request) throws -> Future<Card> {
        return try req.parameters.next(Card.self)
            .flatMap { item in
                return try req.content.decode(Card.self)
                    .flatMap { updatedItem in
                        item.description = updatedItem.description
                        item.numberOfBlanks = updatedItem.numberOfBlanks
                        item.isPrompt = updatedItem.isPrompt
                        
                        return item.save(on: req)
                            .map { item in
                                return item
                        }
                }
        }
    }
    
    func getCards(_ req: Request) throws -> Future<[Card]> {
        _ = try req.requireAuthenticated(User.self)
        return Card.query(on: req).all()
    }
    
    func logout(_ req: Request) throws -> Future<Response> {
        try req.unauthenticateSession(User.self)
        return Future.map(on: req) { return req.redirect(to: "/login") }
    }
}


struct LeafContext: Encodable {
    let title: String
    let user: User?
}

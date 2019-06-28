class RoomSession {
	constructor(id,
	update,
	room) {
		this.id = id;
		this.update = update;
		this.room = room;
	}
}

class RoomUpdate{
	constructor(updateType,
	user,
	isReady) {
		this.updateType = updateType;
		this.user = user;
		this.isReady = isReady;
	}
}

class Room{
	constructor(user) {
		this.user = user;
	}
}

var user = Object();
var userID = 0;
var roomID = "";
var roomUpdate = new RoomUpdate(0, 0, false);
var room = new Room();
var roomSession = new RoomSession(roomID, roomUpdate, room);

var ip = "localhost";
var port = "8080";

function index() {
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
			document.write(this.responseText);
			getAuthUser();
		}
	};
	
	xhttp.open("GET", "http://" + ip + ":" + port + "/", true);
	xhttp.send();
}

//function login() {
//	var xhttp = new XMLHttpRequest();
//	xhttp.onreadystatechange = function () {
//		if (this.readyState == 4 && this.status == 200) {
//			document.write(this.responseText);
//			getAuthUser();
//		}
//	};
//	
//	xhttp.open("GET", "http://" + ip + ":" + port + "/login", true);
//	xhttp.send();
//}

function getAuthUser() {
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
            console.log("getAuthUser(): user: " + this.responseText);
            console.log("getAuthUser(): userID: " + user.id);
            
            user = JSON.parse(this.responseText);
			userID = user.id;
            
            console.log("getAuthUser(): starting lobbyInit()");
            lobbyInit();
            console.log("getAuthUser(): starting updateRoom()");
            updateRoom();
        }
	};
	
	xhttp.open("GET", "http://" + ip + ":" + port + "/getAuthUser", true);
	xhttp.send();
}

function createRoom() {
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
			roomID = this.responseText;
			console.log("createRoom(): new room session: " + roomID);
			document.getElementById("joinRoomCode").value = roomID;
			joinRoom();
		}
	};
	
	xhttp.open("POST", "http://" + ip + ":" + port + "/create", true);
	xhttp.setRequestHeader("Content-type", "application/json");
	xhttp.send();
}

function joinRoom() {
	var id = document.getElementById("joinRoomCode").value;
	roomID = id;
    console.log("joinRoom(): starting websocket");
	var socket = new WebSocket("ws://" + ip + ":" + port + "/join/" + id);
	socket.onmessage = function (event) {
		console.log("event: " + event.data + "\n");
        refreshView();
		//send an update to initialize the room's admin and users
        
		
		//TODO: send another update for GoToLobby
	};
    getAuthUser();
}


function lobbyInit() {
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
			console.log("lobbyInit(): response:" + this.responseText);
			roomSession = JSON.parse(this.responseText);
		}
	};
    
    var update = {
        user: user.id,
        updateType: 0,
        isReady: false
        
    };
    roomSession.update = update;
	
    console.log("lobbyInit(): roomSession.update.user:" + roomSession.update.user);
    console.log("lobbyInit(): roomSession.update.updateType:" + roomSession.update.updateType);
    console.log("lobbyInit(): roomSession.update.isReady:" + roomSession.update.isReady);
    
	xhttp.open("POST", "http://" + ip + ":" + port + "/api/lobby/init/" + roomID, true);
	xhttp.setRequestHeader("Content-type", "application/json");
	xhttp.send(JSON.stringify(roomSession));
}

function refreshView() {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function () {
        if (this.readyState == 4 && this.status == 200) {
            console.log("refreshView(): OK");
            document.open();
            document.write(this.responseText);
            document.close();
        }
    };
    console.log("UPDAETVIEW!!!!");
    xhttp.open("POST", "http://" + ip + ":" + port + "/refreshView/" + roomID, true);
    xhttp.setRequestHeader("Content-type", "application/json");
    
    var update = {
    updateType: 1
    };
    
    roomSession.update = update;
    
    xhttp.send(JSON.stringify(roomSession));
}

function updateRoom() {
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
			console.log("updateRoom(): OK");
            document.open();
			document.write(this.responseText);
            document.close();
		}
	};
	
	xhttp.open("POST", "http://" + ip + ":" + port + "/update/" + roomID, true);
	xhttp.setRequestHeader("Content-type", "application/json");
	xhttp.send(JSON.stringify(roomSession));
}

function unready() {
	roomSession.update.updateType = 1;
	roomSession.update.isReady = false;
    console.log("unready(): starting updateRoom()");
	updateRoom();
}

function ready() {
	roomSession.update.updateType = 1;
	roomSession.update.isReady = true;
    console.log("ready(): starting updateRoom()");
	updateRoom();
}

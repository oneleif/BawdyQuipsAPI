class RoomSession {
	constructor(id, update, room){
			this.id = id;
			this.update = update;
			this.room = room;
	}
}

class RoomUpdate{
	constructor(updateType, user, isReady){
			this.updateType = updateType;
			this.user = user;
			this.isReady = isReady;
	}
}

class Room{
	constructor(user){
			this.user = user;
	}
}

var userID = 0;
var roomID = "";
var roomUpdate = new RoomUpdate(0, 0, 0);
var room = new Room();

var roomSession = new RoomSession(roomID, roomUpdate, room);

var ip = "localhost";
var port = "8080";



function index(){
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
	        document.write(this.responseText);
		}
	};
	
	xhttp.open("GET", "http://" + ip + ":" + port + "/", true);
	xhttp.send();
}

function login(){
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
	        document.write(this.responseText);
			getAuthUser();
		}
	};
	
	xhttp.open("GET", "http://" + ip + ":" + port + "/login", true);
	xhttp.send();
}

function getAuthUser(){
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
			userID = this.responseText;
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
			console.log("new room session: " + roomID);
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
    var socket = new WebSocket("ws://" + ip + ":" + port + "/join/" + id);
	socket.onmessage = function (event) {
		console.log("event: " + event.data + "\n");
        
		//send an update to initialize the room's admin and users
        updateRoom();
		
		//TODO: send another update for GoToLobby
	};
    updateRoom();
}


function updateRoom() {
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
            
			document.write(this.responseText);
		}
	};
	
	xhttp.open("POST", "http://" + ip + ":" + port + "/update/" + roomID, true);
	xhttp.setRequestHeader("Content-type", "application/json");
	xhttp.send(JSON.stringify(roomSession));
}

function unready() {
	roomSession.update.updateType = 1;
	roomSession.update.isReady = false;
	updateRoom();
}

function ready() {
	roomSession.update.updateType = 1;
	roomSession.update.isReady = true;
	updateRoom();
}

var roomSession = Object();
roomSession.id = "";
roomSession.update = Object();
roomSession.update.user = 0; //temp UserID
roomSession.update.scene = 0; //lobby
roomSession.update.updateType = 0; //player joined
roomSession.room = Object();
var port = "8080";

function createRoom() {
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
			var response = JSON.parse(this.responseText);
			roomSession = response;
			console.log("new room session: " + this.responseText);
			document.getElementById("joinRoomCode").value = roomSession.id;
			joinRoom();
		}
	};
	
	xhttp.open("POST", "http://localhost:" + port + "/create", true);
	xhttp.setRequestHeader("Content-type", "application/json");
	xhttp.send();
}

function joinRoom() {
	var id = document.getElementById("joinRoomCode").value;
    var socket = new WebSocket("ws://localhost:" + port + "/join/" + id);
	socket.onmessage = function (event) {
		console.log("event: " + event.data + "\n");
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
	
	xhttp.open("POST", "http://localhost:" + port + "/update/" + roomSession.id, true);
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

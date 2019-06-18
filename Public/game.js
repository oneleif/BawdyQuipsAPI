var roomUpdate = Object();
roomUpdate.update = Object();
roomUpdate.update.user = 0; //temp UserID
roomUpdate.update.scene = 0; //lobby
roomUpdate.update.updateType = 0; //player joined
var port = "8080";

function createRoom() {
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
			var response = JSON.parse(this.responseText);
			roomUpdate = response;
			console.log("new room session: " + this.responseText);
			document.getElementById("joinRoomCode").value = roomUpdate.id;
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
	
	xhttp.open("POST", "http://localhost:" + port + "/update/" + roomUpdate.id, true);
	xhttp.setRequestHeader("Content-type", "application/json");
	xhttp.send(JSON.stringify(roomUpdate));
}

function unready() {
	roomUpdate.update.updateType = 1;
	roomUpdate.update.isReady = false;
	updateRoom();
}

function ready() {
	roomUpdate.update.updateType = 1;
	roomUpdate.update.isReady = true;
	updateRoom();
}

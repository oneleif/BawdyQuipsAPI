var user = Object();
var userID = 0;

var update = {
	updateType: 0,
	user: 0,
	isReady: false
};

var room = {
	user: 0
};

var roomSession = {
	id: "",
	update: update,
	room: room
};

var ip = "localhost";
var port = "8080";

// View Handlers
function index() {
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
			document.body.innerHTML = this.responseText;
			getAuthUser();
		}
	};
	
	xhttp.open("GET", "http://" + ip + ":" + port + "/", true);
	xhttp.send();
}

function getAuthUser() {
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
            user = JSON.parse(this.responseText);
			userID = user.id;
            
            lobbyInit();
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
			roomSession.id = this.responseText;
			document.getElementById("joinRoomCode").value = roomSession.id;
			joinRoom();
		}
	};
	
	xhttp.open("POST", "http://" + ip + ":" + port + "/create", true);
	xhttp.setRequestHeader("Content-type", "application/json");
	xhttp.send();
}

function joinRoom() {
	getAuthUser();
	roomSession.id = document.getElementById("joinRoomCode").value;
	
	var socket = new WebSocket("ws://" + ip + ":" + port + "/join/" + roomSession.id);
	socket.onmessage = function (event) {
        refreshView();
	};
}

function getAuthUser() {
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
		user = JSON.parse(this.responseText);
		userID = user.id;
		lobbyInit();
		sendJoinedRoomUpdate();
	  }
	};
	
	xhttp.open("GET", "http://" + ip + ":" + port + "/getAuthUser", true);
	xhttp.send();
}

function lobbyInit() {
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
			roomSession = JSON.parse(this.responseText);
		}
	};

    var update = {
        user: user.id,
        updateType: 0,
        isReady: false
    };
	
    roomSession.update = update;
	
	xhttp.open("POST", "http://" + ip + ":" + port + "/api/lobby/init/" + roomSession.id, true);
	xhttp.setRequestHeader("Content-type", "application/json");
	xhttp.send(JSON.stringify(roomSession));
}

function refreshView() {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function () {
        if (this.readyState == 4 && this.status == 200) {
            document.body.innerHTML = this.responseText;
        }
    };
    xhttp.open("POST", "http://" + ip + ":" + port + "/updateView/" + roomSession.id, true);
    xhttp.setRequestHeader("Content-type", "application/json");
    xhttp.send(JSON.stringify(roomSession));
}

// ALL room updates are passed through here
function sendRoomUpdate() {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function () {
        if (this.readyState == 4 && this.status == 200) {
            document.body.innerHTML = this.responseText;
        }
    };

    xhttp.open("POST", "http://" + ip + ":" + port + "/update/" + roomSession.id, true);
    xhttp.setRequestHeader("Content-type", "application/json");
    xhttp.send(JSON.stringify(roomSession));
}

function sendJoinedRoomUpdate() {
    // Send player joined request
	var update = {
		updateType: 0
    };
    
    roomSession.update = update;
	sendRoomUpdate();
}

function ready() {
	roomSession.update.updateType = 1;
	roomSession.update.isReady = !roomSession.update.isReady;
	sendRoomUpdate();
}

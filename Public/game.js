var user = Object();
var userID = 0;


var roomID = "";

var update = {
	updateType: 0,
	user: 0,
	isReady: false
};

var room = {
	user: 0
};

var roomSession = {
	roomID: roomID,
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
			document.write(this.responseText);
			getAuthUser();
		}
	};
	
	xhttp.open("GET", "http://" + ip + ":" + port + "/", true);
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
	getAuthUser();
	var id = document.getElementById("joinRoomCode").value;
	roomID = id;
	
    console.log("joinRoom(): starting websocket");
	var socket = new WebSocket("ws://" + ip + ":" + port + "/join/" + id);
	socket.onmessage = function (event) {
		console.log("event: " + event.data + "\n");
        updateView();
	};
}

function getAuthUser() {
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
		user = JSON.parse(this.responseText);
			userID = user.id;
		console.log("getAuthUser(): user: " + this.responseText);
		console.log("getAuthUser(): userID: " + userID);
		console.log("getAuthUser(): starting lobbyInit()");
		lobbyInit();
		console.log("getAuthUser(): starting updateRoom()");
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

function updateView() {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function () {
        if (this.readyState == 4 && this.status == 200) {
            console.log("UPDATEVIEW(): OK");
            document.open();
            document.write(this.responseText);
            document.close();
        }
    };
    console.log("UpdateView(): roomID: " + roomID);
    xhttp.open("POST", "http://" + ip + ":" + port + "/updateView/" + roomID, true);
    xhttp.setRequestHeader("Content-type", "application/json");
    
    xhttp.send(JSON.stringify(roomSession));
}

// ALL room updates are passed through here
function sendRoomUpdate() {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function () {
        if (this.readyState == 4 && this.status == 200) {
            console.log("updateRoom(): OK");
            document.open();
            document.write(this.responseText);
            document.close();
        }
    };
    
	console.log("sendRoomUpdate(): roomID: " + roomID)
    xhttp.open("POST", "http://" + ip + ":" + port + "/update/" + roomID, true);
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
    console.log("ready(): starting updateRoom()");
	sendRoomUpdate();
}

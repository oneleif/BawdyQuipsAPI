let user = Object();
let userID = 0;

let update = {
	updateType: 0,
	user: 0,
	isReady: false
};

let room = {
	user: 0
};

let roomSession = {
	id: "",
	update: update,
	room: room
};

const ip = "localhost";
const port = "8080";

function register() {
	const xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
			document.body.innerHTML = this.responseText;
		}
	};
	let newUser = {};
	newUser.username = document.getElementById("username").value;
	newUser.password = document.getElementById("password").value;

	xhttp.open("POST", "http://" + ip + ":" + port + "/register", true);
	xhttp.setRequestHeader("Content-type", "application/json");
	xhttp.send(JSON.stringify(newUser));
}

function login() {
	const xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
			document.body.innerHTML = this.responseText;
			getAuthUser();
		}
	};
	let userLogin = {};
	userLogin.username = document.getElementById("username").value;
	userLogin.password = document.getElementById("password").value;

	xhttp.open("POST", "http://" + ip + ":" + port + "/login", true);
	xhttp.setRequestHeader("Content-type", "application/json");
	xhttp.send(JSON.stringify(userLogin));
}


function getAuthUser() {
	const xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
            user = JSON.parse(this.responseText);
			userID = user.id;
        }
	};
	xhttp.open("GET", "http://" + ip + ":" + port + "/getAuthUser", true);
	xhttp.send();
}

function createRoom() {
	const xhttp = new XMLHttpRequest();
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
	roomSession.id = document.getElementById("joinRoomCode").value;

	const socket = new WebSocket("ws://" + ip + ":" + port + "/join/" + roomSession.id);
	socket.onmessage = function (event) {
		console.log("websocket event: " + event.data);
        roomSession = JSON.parse(event.data);
        updateView();
	};

	lobbyInit();
}

function lobbyInit() {
	const xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function () {
		if (this.readyState == 4 && this.status == 200) {
			roomSession = JSON.parse(this.responseText);
			console.log("lobbyInit() roomSession returned: " + this.responseText);
			updateView();
		}
	};

	//TODO its breaking here and not sending the user
    let update = {
        user: user.id,
        updateType: 0,
        isReady: false
    };
	
    roomSession.update = update;

	console.log("lobbyInit(): sent roomSession: " + JSON.stringify(roomSession));
	xhttp.open("POST", "http://" + ip + ":" + port + "/api/lobby/init/" + roomSession.id, true);
	xhttp.setRequestHeader("Content-type", "application/json");
	xhttp.send(JSON.stringify(roomSession));

}

function updateView() {
	const xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function () {
        if (this.readyState == 4 && this.status == 200) {
            document.body.innerHTML = this.responseText;
        }
    };

	// let update = {
	// 	user: user.id,
	// 	updateType: 0,
	// 	isReady: false
	// };
	//
	// roomSession.update = update;

	console.log("updateView() requesting updateType: " + roomSession.update.updateType);
    xhttp.open("POST", "http://" + ip + ":" + port + "/updateView/" + roomSession.id, true);
    xhttp.setRequestHeader("Content-type", "application/json");
    xhttp.send(JSON.stringify(roomSession));

}

// ALL room updates are passed through here
function sendRoomUpdate() {
	const xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function () {
        if (this.readyState == 4 && this.status == 200) {
            document.body.innerHTML = this.responseText;
        }
    };

    xhttp.open("POST", "http://" + ip + ":" + port + "/update/" + roomSession.id, true);
    xhttp.setRequestHeader("Content-type", "application/json");
    xhttp.send(JSON.stringify(roomSession));
    console.log("update(): sending updateType: " + roomSession.update.updateType);
}

function sendJoinedRoomUpdate() {
    // Send player joined request
	let update = {
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

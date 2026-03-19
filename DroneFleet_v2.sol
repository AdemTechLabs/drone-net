// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DroneFleet {
    enum Role { None, Technicien, Pilote, Admin }

    struct Drone {
        uint256 id;
        string model;
        string status;
        bool isActive;
        bool isDeleted;
        int256 posX;
        int256 posY;
        int256 altitude;
        uint8 formationSlot;
    }

    struct User {
        string name;
        Role role;
        bool isRegistered;
    }

    address public owner;
    uint256 public dronesCount;
    mapping(address => User) public users;
    mapping(uint256 => Drone) public drones;

    // Swarm leader
    uint256 public swarmLeaderId;
    bool public swarmModeActive;

    // Formation types: 0=none 1=V 2=line 3=circle
    uint8 public currentFormation;

    event DroneMove(uint256 indexed id, int256 posX, int256 posY, int256 altitude, string direction);
    event FormationSet(uint8 formationType, uint256 leaderId);
    event SwarmActivated(uint256 leaderId, bool active);
    event WaypointReached(uint256 indexed id, int256 posX, int256 posY);
    event TargetLocked(uint256 indexed droneId, int256 targetX, int256 targetY);

    modifier onlyAdmin() {
        require(users[msg.sender].role == Role.Admin || msg.sender == owner, "Admin requis");
        _;
    }
    modifier onlyAuthorized() {
        require(
            users[msg.sender].role == Role.Admin ||
            users[msg.sender].role == Role.Pilote,
            "Acces Pilote/Admin requis"
        );
        _;
    }
    modifier droneOperational(uint256 _id) {
        require(drones[_id].isActive && !drones[_id].isDeleted, "Drone HS");
        _;
    }

    constructor() {
        owner = msg.sender;
        users[msg.sender] = User("Commandant", Role.Admin, true);
    }

    function registerUser(string memory _name, uint8 _roleChoice) public {
        require(!users[msg.sender].isRegistered, "Deja enregistre");
        users[msg.sender] = User(_name, Role(_roleChoice), true);
    }

    function getMyProfile() public view returns (string memory, Role) {
        return (users[msg.sender].name, users[msg.sender].role);
    }

    function addDrone(string memory _model, string memory _status) public onlyAdmin {
        dronesCount++;
        drones[dronesCount] = Drone(
            dronesCount, _model, _status, true, false,
            int256(dronesCount) * 50, 0, 100, 0
        );
    }

    function toggleMaintenance(uint256 _id) public onlyAdmin {
        drones[_id].isActive = !drones[_id].isActive;
    }

    function deleteDrone(uint256 _id) public onlyAdmin {
        drones[_id].isDeleted = true;
        drones[_id].isActive = false;
    }

    // ── MOUVEMENT ÉTENDU ──
    // Directions: N S E O NE NO SE SO UP DOWN
    function moveDrone(uint256 _id, string memory _direction)
        public onlyAuthorized droneOperational(_id)
    {
        int256 step = 10;
        int256 altStep = 20;
        Drone storage d = drones[_id];

        bytes32 dir = keccak256(bytes(_direction));
        if (dir == keccak256("N"))  { d.posY += step; }
        else if (dir == keccak256("S"))  { d.posY -= step; }
        else if (dir == keccak256("E"))  { d.posX += step; }
        else if (dir == keccak256("O"))  { d.posX -= step; }
        else if (dir == keccak256("NE")) { d.posX += step; d.posY += step; }
        else if (dir == keccak256("NO")) { d.posX -= step; d.posY += step; }
        else if (dir == keccak256("SE")) { d.posX += step; d.posY -= step; }
        else if (dir == keccak256("SO")) { d.posX -= step; d.posY -= step; }
        else if (dir == keccak256("UP")) { d.altitude += altStep; }
        else if (dir == keccak256("DOWN")) {
            if (d.altitude > altStep) d.altitude -= altStep;
        }

        d.status = string(abi.encodePacked("Cap: ", _direction));

        // Swarm: followers move with leader
        if (swarmModeActive && _id == swarmLeaderId) {
            for (uint256 i = 1; i <= dronesCount; i++) {
                if (i == _id || !drones[i].isActive || drones[i].isDeleted) continue;
                int256 dx = drones[_id].posX - int256(i) * 50;
                drones[i].posX = drones[_id].posX - int256(i) * 15;
                drones[i].posY = drones[_id].posY - int256(i) * 8;
                drones[i].altitude = drones[_id].altitude;
                drones[i].status = "SWARM_FOLLOW";
            }
        }

        emit DroneMove(_id, d.posX, d.posY, d.altitude, _direction);
    }

    // ── WAYPOINT ──
    function moveToWaypoint(uint256 _id, int256 _targetX, int256 _targetY, int256 _targetAlt)
        public onlyAuthorized droneOperational(_id)
    {
        drones[_id].posX = _targetX;
        drones[_id].posY = _targetY;
        drones[_id].altitude = _targetAlt;
        drones[_id].status = string(abi.encodePacked("WP:", int2str(_targetX), ",", int2str(_targetY)));
        emit WaypointReached(_id, _targetX, _targetY);
    }

    // ── INTERCEPTION / LOCK TARGET ──
    function lockTarget(uint256 _droneId, int256 _targetX, int256 _targetY)
        public onlyAuthorized droneOperational(_droneId)
    {
        drones[_droneId].posX = _targetX;
        drones[_droneId].posY = _targetY;
        drones[_droneId].status = "TARGET_LOCKED";
        emit TargetLocked(_droneId, _targetX, _targetY);
    }

    // ── FORMATION ──
    function setFormation(uint8 _type, uint256 _leaderId)
        public onlyAuthorized droneOperational(_leaderId)
    {
        currentFormation = _type;
        swarmLeaderId = _leaderId;
        _applyFormation(_type, _leaderId);
        emit FormationSet(_type, _leaderId);
    }

    function _applyFormation(uint8 _type, uint256 leaderId) internal {
        int256 lx = drones[leaderId].posX;
        int256 ly = drones[leaderId].posY;
        int256 la = drones[leaderId].altitude;
        uint256 slot = 1;
        for (uint256 i = 1; i <= dronesCount; i++) {
            if (i == leaderId || !drones[i].isActive || drones[i].isDeleted) continue;
            if (_type == 1) { // V
                int256 sign = (slot % 2 == 0) ? int256(1) : int256(-1);
                drones[i].posX = lx + sign * int256(slot) * 20;
                drones[i].posY = ly - int256(slot) * 15;
                drones[i].altitude = la;
            } else if (_type == 2) { // Ligne
                drones[i].posX = lx + int256(slot) * 25;
                drones[i].posY = ly;
                drones[i].altitude = la;
            } else if (_type == 3) { // Cercle
                int256 angle = int256(slot) * 60;
                drones[i].posX = lx + int256(slot) * 20;
                drones[i].posY = ly + (angle > 180 ? int256(-1) : int256(1)) * 20;
                drones[i].altitude = la;
            }
            drones[i].status = "FORMATION";
            drones[i].formationSlot = uint8(slot);
            slot++;
        }
    }

    // ── SWARM MODE ──
    function toggleSwarm(uint256 _leaderId) public onlyAuthorized droneOperational(_leaderId) {
        swarmModeActive = !swarmModeActive;
        swarmLeaderId = _leaderId;
        emit SwarmActivated(_leaderId, swarmModeActive);
    }

    // ── SCAN ──
    function runReconnaissance(uint256 _id) public onlyAuthorized droneOperational(_id) {
        drones[_id].status = "SCAN_EN_COURS";
    }
    function stopAction(uint256 _id) public onlyAuthorized droneOperational(_id) {
        drones[_id].status = "EN_ATTENTE";
    }

    function getDronePosition(uint256 _id) public view returns (int256, int256, int256) {
        return (drones[_id].posX, drones[_id].posY, drones[_id].altitude);
    }

    function int2str(int256 v) internal pure returns (string memory) {
        if (v == 0) return "0";
        bool neg = v < 0;
        uint256 u = neg ? uint256(-v) : uint256(v);
        bytes memory b;
        while (u > 0) { b = abi.encodePacked(bytes1(uint8(48 + u % 10)), b); u /= 10; }
        if (neg) b = abi.encodePacked("-", b);
        return string(b);
    }
}

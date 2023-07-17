// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HemoglobinData {
    struct HemoglobinRecord {
        uint256 timestamp;
        uint256 level;
    }

    struct Hospital {
        bool exists;
        bool approved;
    }

    mapping(address => mapping(uint256 => HemoglobinRecord)) private records;
    mapping(address => uint256[]) private babyRecords;
    mapping(address => mapping(address => Hospital)) private hospitalAccess;

    event HemoglobinAdded(address indexed babyAddress, uint256 indexed recordIndex, uint256 timestamp, uint256 level);
    event HospitalAccessRequested(address indexed babyAddress, address indexed hospitalAddress);
    event HospitalAccessApproved(address indexed babyAddress, address indexed hospitalAddress);
    event HospitalAccessRevoked(address indexed babyAddress, address indexed hospitalAddress);

    modifier onlyBabyOrApprovedHospital(address babyAddress) {
        require(babyAddress != address(0), "Invalid baby address");
        require(
            msg.sender == babyAddress || hospitalAccess[babyAddress][msg.sender].approved,
            "Access denied"
        );
        _;
    }

    function addHemoglobinRecord(address babyAddress, uint256 timestamp, uint256 level) external onlyBabyOrApprovedHospital(babyAddress) {
        require(level > 0, "Invalid hemoglobin level");

        HemoglobinRecord memory newRecord = HemoglobinRecord(timestamp, level);
        uint256 recordIndex = babyRecords[babyAddress].length;
        babyRecords[babyAddress].push(recordIndex);
        records[babyAddress][recordIndex] = newRecord;

        emit HemoglobinAdded(babyAddress, recordIndex, timestamp, level);
    }

    function getHemoglobinRecordCount(address babyAddress) external view returns (uint256) {
        require(babyAddress != address(0), "Invalid baby address");
        return babyRecords[babyAddress].length;
    }

    function getHemoglobinRecord(address babyAddress, uint256 recordIndex) external view returns (uint256, uint256) {
        require(babyAddress != address(0), "Invalid baby address");
        require(recordIndex < babyRecords[babyAddress].length, "Invalid record index");

        HemoglobinRecord memory record = records[babyAddress][recordIndex];
        return (record.timestamp, record.level);
    }

    function requestHospitalAccess(address babyAddress) external {
        require(babyAddress != address(0), "Invalid baby address");

        hospitalAccess[babyAddress][msg.sender].exists = true;
        emit HospitalAccessRequested(babyAddress, msg.sender);
    }

    function approveHospitalAccess(address babyAddress, address hospitalAddress) external onlyBabyOrApprovedHospital(babyAddress) {
        require(babyAddress != address(0), "Invalid baby address");
        require(hospitalAddress != address(0), "Invalid hospital address");

        hospitalAccess[babyAddress][hospitalAddress].approved = true;
        emit HospitalAccessApproved(babyAddress, hospitalAddress);
    }

    function revokeHospitalAccess(address babyAddress, address hospitalAddress) external onlyBabyOrApprovedHospital(babyAddress) {
        require(babyAddress != address(0), "Invalid baby address");
        require(hospitalAddress != address(0), "Invalid hospital address");

        hospitalAccess[babyAddress][hospitalAddress].approved = false;
        emit HospitalAccessRevoked(babyAddress, hospitalAddress);
    }

    function checkHospitalAccess(address babyAddress, address hospitalAddress) external view returns (bool) {
        require(babyAddress != address(0), "Invalid baby address");
        require(hospitalAddress != address(0), "Invalid hospital address");

        return hospitalAccess[babyAddress][hospitalAddress].approved;
    }
}

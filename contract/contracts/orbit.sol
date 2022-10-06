// SPDX-License-Ientifier: MIT
pragma solidity ^0.8.0;

// contract address = '0xf33685bE8aB8897b91AB3959c35834B1a126032f'

contract orbit {
    address payable dexAdmin;
    uint public  recruitersFee;

    constructor(address payable wagmi) {
        dexAdmin = wagmi;
    }

    // dexFunction
    function initFee(uint _fee) external {
        require(msg.sender == dexAdmin);
        recruitersFee = _fee;
    }

    address payable[] public recruiters;
    mapping(address => uint) public recruitee;
    mapping(address => Status) public newbie;
    mapping(address => Status) public verificationSat; 

    function beRecruiter(uint gateFee, address payable recruitersId) external payable {
        gateFee = msg.value;
        require(gateFee == recruitersFee && recruitersId == msg.sender);
        recruiters.push(recruitersId);
        dexAdmin.transfer(gateFee);
    }
    enum Status{
            verify,
            unverify
        }

    function beRecruitee(uint grade, address payable recruiteeId, uint charge) external {
        require(recruiteeId == msg.sender);       
        if(grade < 10 && grade > 6) {
            verificationSat[recruiteeId] = Status.verify;
            if(verificationSat[recruiteeId]  == Status.verify) {
                recruitee[recruiteeId] = charge;
            }
        }
        else {
            verificationSat[recruiteeId] = Status.unverify;
            newbie[recruiteeId] = Status.unverify;
            delete recruitee[recruiteeId];
        }
    }

    enum listing {
        non,
        hire,
        work
    }

    mapping (address => listing) public hired;
    mapping (address => listing) public workers;

    function hire(uint charges, address payable client) external payable {
        for(uint i = 0; i < recruiters.length; i++) {
            require(msg.sender == recruiters[i]);
        } 
        require(verificationSat[client] == Status.verify);
        require(recruitee[client] == charges);
        charges = msg.value;
        dexAdmin.transfer(charges);
        hired[client] = listing.hire;
        }

        function work(address yourId) external {
            require(hired[yourId] == listing.hire);
            require (msg.sender == yourId);
            workers[yourId] = listing.work;            
        }

        modifier onlyAdmin {
          require(msg.sender == dexAdmin);
            _;
        }

        function getPaid(address payable worker, uint salary) external payable onlyAdmin {
            require (hired[worker] == listing.hire); 
            require(workers[worker] == listing.work);
            require(recruitee[worker] == salary);
            salary = msg.value;
            worker.transfer(salary * 25 / 100);
        }

    
}

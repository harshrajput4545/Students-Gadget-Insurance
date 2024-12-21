// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StudentGadgetInsurance {
    struct Gadget {
        string name;
        uint256 value;
        bool insured;
    }

    struct InsurancePolicy {
        address student;
        uint256 premium;
        uint256 coverageAmount;
        bool active;
    }

    mapping(address => mapping(uint256 => Gadget)) public studentGadgets;
    mapping(address => InsurancePolicy) public insurancePolicies;
    mapping(address => uint256) public studentBalances;
    uint256 public policyCount;

    // Event declarations
    event GadgetRegistered(address indexed student, uint256 gadgetId, string name, uint256 value);
    event InsurancePurchased(address indexed student, uint256 premium, uint256 coverageAmount);
    event ClaimFiled(address indexed student, uint256 amountClaimed);

    modifier onlyStudent(address student) {
        require(msg.sender == student, "You are not the student owner.");
        _;
    }

    modifier onlyActivePolicy(address student) {
        require(insurancePolicies[student].active, "No active insurance policy.");
        _;
    }

    function registerGadget(uint256 gadgetId, string memory name, uint256 value) public {
        require(value > 0, "Gadget value must be greater than 0.");
        studentGadgets[msg.sender][gadgetId] = Gadget(name, value, false);
        emit GadgetRegistered(msg.sender, gadgetId, name, value);
    }

    function purchaseInsurance(uint256 premium, uint256 coverageAmount) public payable {
        require(msg.value == premium, "Incorrect premium amount sent.");
        require(coverageAmount > 0, "Coverage amount must be greater than 0.");

        insurancePolicies[msg.sender] = InsurancePolicy({
            student: msg.sender,
            premium: premium,
            coverageAmount: coverageAmount,
            active: true
        });

        studentBalances[msg.sender] += msg.value;
        emit InsurancePurchased(msg.sender, premium, coverageAmount);
    }

    function fileClaim(uint256 gadgetId) public onlyStudent(msg.sender) onlyActivePolicy(msg.sender) {
        Gadget storage gadget = studentGadgets[msg.sender][gadgetId];
        require(gadget.insured, "Gadget is not insured.");
        uint256 claimAmount = gadget.value > insurancePolicies[msg.sender].coverageAmount ? 
                              insurancePolicies[msg.sender].coverageAmount : gadget.value;
        studentBalances[msg.sender] -= claimAmount;
        emit ClaimFiled(msg.sender, claimAmount);
    }

    function insureGadget(uint256 gadgetId) public {
        Gadget storage gadget = studentGadgets[msg.sender][gadgetId];
        require(!gadget.insured, "Gadget is already insured.");
        gadget.insured = true;
    }

    function deactivatePolicy() public onlyActivePolicy(msg.sender) {
        insurancePolicies[msg.sender].active = false;
    }
}

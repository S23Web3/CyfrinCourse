// SPDX-License-Identifier: MIT
pragma solidity  0.8.18;

contract SimpleStorage {
    // an empty variable gets initialized as 0. It value is deposited in the storage area of the contract
    uint256 myfavoriteNumber; 

    // This is a struct, where I can combine different types under a new custom type
    struct Person {
        uint256 favoriteNumber;
        string name;
    }

    // this is wrong because mapping only needs to know the types first
    //mapping (string name => uint256 favoriteNumber) nameToNumber;
    mapping(string=>uint256) public nameToFavoriteNumber;
    //the values inside are just as a dictionary and although the values are the same, the question is whether the data location is also the same

    // this is a list initialized empty with 0 Persson objects
    Person[] public listofPeople;

    function store (uint256 _favoriteNumber) public{
        //the underscore _ before favorite number is not a functionality but a way to make it a different name
        myfavoriteNumber = _favoriteNumber;
    }

    function retrieve () public view returns (uint256){
        return myfavoriteNumber;
    }

    function addPerson(uint256 _favoriteNumber, string memory _name) public{
        // this is not possible because we are pushing uint256 and strings into an array of Person types  
        //listofPeople.push(_favoriteNumber, _name);
        // so we have to push in a Person that takes the two variables given in next to the function name

        listofPeople.push(Person(_favoriteNumber, _name));
        // sidenote here, memory and calldata are almost the same where calldata can not be modified in the function while memory can
        // storage after string is not possible since it is used temporarily and after the function it does not need to be existent.

        // inside the mapping above on the index of name it : to the relative fav num
        nameToFavoriteNumber[_name] = _favoriteNumber;
    }
}

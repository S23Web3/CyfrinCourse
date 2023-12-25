/*This contract will be able to launch simple storage contracts.
  It is part of the first lessons (up to 3-5 at the moment of writing
  This particular contract launches a contract from within a contract. 
  I went to the course several times, this is one of the last times it will be created from within Github.
  Next ones will be launched from the code editor.
  
*/
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
contract StorageFactory {
// make a new variable of simplestorage
    SimpleStorage public simpleStorage;

    // make a new simplestorage contract and override the previous made variable.
    function createSimpleStorage () public {
        simpleStorage = new SimpleStorage();
    }
 function sfStore(uint256 _indexOfContract, uint256 _storageNumber) public{
        //first we need to select the contract from the list, get it and set it in a variable to interact with
        //first the type then the variable = then the list [index] because the name of the variable has to be something
        //userdefined, uint, address etc
        SimpleStorage thisSimpleStorage = listOfSimpleStorageContracts[_indexOfContract];
        thisSimpleStorage.store(_storageNumber);

        //there is a simpler way listOfSimpleStorageContracts[_indexOfContract].store(_storageNumber);
        // i am not using this now because it is taking away the perspective of understanding the work
         

    }

    function sfRetrieve(uint256 _indexOfContract) public view returns(uint256){
        /*this function gets from the contract out of the list of contracts set above (listOfSimpleStorageContracts)
        the function retrieve and executes it.
        */
        SimpleStorage thisSimpleStorage = listOfSimpleStorageContracts[_indexOfContract];
        /*
        The error you're seeing is due to the fact that you're attempting to return a function (retrieve) instead of the result of calling that function. In Solidity, functions are first-class citizens, meaning they can be assigned to variables, stored in data structures, passed as arguments to other functions, etc. But in order to execute a function, you need to call it using parentheses ().
        Although it returns an uint256 it needs to give it inside the function hence there must be parameters after the retrieve call
        return thisSimpleStorage.retrieve;
        */
        return thisSimpleStorage.retrieve();
    }
} 

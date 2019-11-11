pragma solidity 0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false
    mapping(address => Airline) internal airlines;
    mapping(string => Flight) private flights;
    mapping(address => string) private insurances;
    mapping(address => uint) private fundsLedger;
    uint private totalAirlines = 0;
    uint private flightsCount = 0;

    struct Airline {
        address airlineAddress;
        bool isRegistered;
        string name;
        uint8 voteCount;
        mapping(address => bool) voters;
    }

    struct Flight {
        string flight;
        bool isRegistered;
        uint8 statusCode;
        uint256 updatedTimestamp;
        address airline;
    }
    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/


    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor
                                (
                                    address firstAirlineAddress
                                )
                                public
    {
        contractOwner = msg.sender;
        airlines[firstAirlineAddress] = Airline(firstAirlineAddress,false,"First Airline",0);
        airlines[firstAirlineAddress].isRegistered = true;
        totalAirlines = totalAirlines + 1;
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational()
    {
        require(operational, "Contract is currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */
    function isOperational()
                            public
                            view
                            returns(bool)
    {
        return operational;
    }


    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */
    function setOperatingStatus
                            (
                                bool mode
                            )
                            external
                            requireContractOwner
    {
        operational = mode;
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

    function isAirlineRegistered (address airlineAddress) external returns(bool)
    {
        return airlines[airlineAddress].isRegistered;
    }

    function isAirlineAlreadyProcessed (address airlineAddress) external returns(bool)
    {

        if(airlines[airlineAddress].airlineAddress != address(0)){
            return true;
        }else{
            return false;
        }
    }

   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    */
    function registerAirline
                            (
                                address voter,
                                address airlineAddress,
                                string name
                            )
                            requireIsOperational()
                            external
                            view
    {
        if(airlines[airlineAddress].airlineAddress != address(0)){
            checkAirlineStatus(voter,airlineAddress);
        }else{
            airlines[airlineAddress] = Airline(airlineAddress,false,name,0);
            checkAirlineStatus(voter,airlineAddress);
        }
    }

    function isAirline
                        (
                            address airlineAddress
                        )
                        requireIsOperational()
                        public
                        view
                        returns(bool)
    {
        if(airlines[airlineAddress].airlineAddress != address(0)){
            return airlines[airlineAddress].isRegistered ;
        }else{
            return false;
        }
    }


    function checkAirlineStatus
    (
        address voter,
        address airlineAddress
    )
    requireIsOperational()
    internal
    {
        if(totalAirlines > 4){
            //Check if this airline voted before
            if(!airlines[airlineAddress].voters[voter]){
                airlines[airlineAddress].voters[voter] = true;
                airlines[airlineAddress].voteCount = airlines[airlineAddress].voteCount + 1;
            }

            //Check vote count for consensus
            if( airlines[airlineAddress].voteCount > (totalAirlines / 2)){
                airlines[airlineAddress].isRegistered = true;
                totalAirlines = totalAirlines + 1;
            }
        }else{
            //If there are less then 4 airlines then register this airline
            airlines[airlineAddress].isRegistered = true;
            totalAirlines = totalAirlines + 1;
        }
    }

    function registerFlight
                            (
                                string code,
                                address airline,
                                uint256 timestamp
                            )
                            requireIsOperational()
                            external
    {
        flightsCount = flightsCount.add(1);
        flights[code] = Flight({
                flight: code,
                isRegistered: true,
                statusCode: 0,
                updatedTimestamp: timestamp,
                airline: airline
            });
    }

    function getFlight
                            (
                                string code
                            )
                            public
                            view
                            returns (string flight , bool isRegistered, uint8 statusCode,uint256 updatedTimestamp,address airline)
    {
        Flight FL = flights[code];
        return (FL.flight,FL.isRegistered,FL.statusCode,FL.updatedTimestamp,FL.airline);
    }

    function processFlightStatus
                            (
                                string code,
                                uint8 statusCode,
                                uint256 timestamp
                            )
                            external
                             
    {
        flights[code].statusCode = statusCode;
        flights[code].updatedTimestamp = timestamp;
    }

   /**
    * @dev Buy insurance for a flight
    *
    */
    function buy
                            (
                                string flightCode,
                                uint paidAmount,
                                address passenger
                            )
                            requireIsOperational()
                            external
    {
        fundsLedger[passenger] = fundsLedger[passenger].add(paidAmount);
        insurances[passenger] = flightCode;
    }

    /**
     *  @dev Credits payouts to insurees
    */
    function creditInsurees
                                (
                                    address passenger,
                                    uint credit,
                                    bytes32 key
                                )
                                requireIsOperational()
                                external
    {

    }

    function getInsurance
                                (
                                    address passenger
                                )
                                requireIsOperational()
                                public
                                view
                                returns (string flightCode)
    {
        return insurances[passenger];
    }

    function getCreditedAmount
                                (
                                    address passenger
                                    )
                                requireIsOperational()
                                public
                                view
                                returns (uint amountCredited)
    {
        return fundsLedger[passenger];
    }

    function withdrawCreditedAmount
                        (
                            uint amount,
                            address passenger
                        )
                        requireIsOperational()
                        public
                        payable
    {
        fundsLedger[passenger] = fundsLedger[passenger].sub(amount);
    }

    function getFlightKey
                        (
                            address airline,
                            string flight
                        )
                        internal
                        returns(bytes32)
    {
        return keccak256(abi.encodePacked(airline, flight));
    }

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    function()
                            external
                            payable
    {
    }


}


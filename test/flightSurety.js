
var Test = require('../config/testConfig.js');
var BigNumber = require('bignumber.js');
const FlightSuretyData  = artifacts.require("FlightSuretyData");
const FlightSuretyApp  = artifacts.require("FlightSuretyApp");

contract('Flight Surety Tests', async (accounts) => {

  var config;
  before('setup contract', async () => {
    config = await Test.Config(accounts);
  });

  /****************************************************************************************/
  /* Operations and Settings                                                              */
  /****************************************************************************************/

  it(`(multiparty) has correct initial isOperational() value`, async function () {

    // Get operating status
    let status = await config.flightSuretyData.isOperational.call();
    assert.equal(status, true, "Incorrect initial operating status value");
    
  });

  it(`(multiparty) can block access to setOperatingStatus() for non-Contract Owner account`, async function () {

      // Ensure that access is denied for non-Contract Owner account
      let accessDenied = false;
      try 
      {
          await config.flightSuretyData.setOperatingStatus(false, { from: config.testAddresses[2] });
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, true, "Access not restricted to Contract Owner");
            
  });

  it(`(multiparty) can allow access to setOperatingStatus() for Contract Owner account`, async function () {

      // Ensure that access is allowed for Contract Owner account
      let accessDenied = false;
      try 
      {
          await config.flightSuretyData.setOperatingStatus(false);
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, false, "Access not restricted to Contract Owner");
      
  });

  it(`(multiparty) can block access to functions using requireIsOperational when operating status is false`, async function () {

      await config.flightSuretyData.setOperatingStatus(false);

      let reverted = false;
      try 
      {
          await config.flightSurety.setTestingMode(true);
      }
      catch(e) {
          reverted = true;
      }
      assert.equal(reverted, true, "Access not blocked for requireIsOperational");      

      // Set it back for other tests to work
      await config.flightSuretyData.setOperatingStatus(true);

  });

  it('(multiparty) can register airline if there is less than 4 airline , if there is not then it needs voting', async () => {
    
    // ARRANGE
    let newAirline3 = accounts[3];
    let newAirline4 = accounts[4];
    let newAirline5 = accounts[5];
    let newAirline6 = accounts[6];
    let newAirline7 = accounts[7];

    // ACT
    try {
        await config.flightSuretyApp.registerAirline(newAirline3,"Airline3", {from: config.firstAirline});
        await config.flightSuretyApp.registerAirline(newAirline4,"Airline4", {from: config.firstAirline});
        await config.flightSuretyApp.registerAirline(newAirline5,"Airline5", {from: config.firstAirline});
        await config.flightSuretyApp.registerAirline(newAirline6,"Airline6", {from: config.firstAirline});
        await config.flightSuretyApp.registerAirline(newAirline7,"Airline7", {from: config.firstAirline});
    }
    catch(e) {
        console.log("ERROR",e)
    }

    let resultAirline3 = await config.flightSuretyData.isAirline.call(newAirline3);
    let resultAirline4 = await config.flightSuretyData.isAirline.call(newAirline4); 
    let resultAirline5 = await config.flightSuretyData.isAirline.call(newAirline5); 
    let resultAirline6 = await config.flightSuretyData.isAirline.call(newAirline6);
    let resultAirline7 = await config.flightSuretyData.isAirline.call(newAirline7);

    // ASSERT
    assert.equal(resultAirline3, true, "There is more than 4 airlines registered");
    assert.equal(resultAirline4, true, "There is more than 4 airlines registered");
    assert.equal(resultAirline5, true, "There is more than 4 airlines registered");
    assert.equal(resultAirline6, true, "There is more than 4 airlines registered");

    //airline 6 should be voted so it is not registered yet
    assert.equal(resultAirline7, false, "There is more than 4 airlines registered");

    try {
        await config.flightSuretyApp.registerAirline(newAirline7,"Airline 3 votes Airline 7", {from: newAirline3});
        await config.flightSuretyApp.registerAirline(newAirline7,"Airline 4 votes Airline 7", {from: newAirline4});
        await config.flightSuretyApp.registerAirline(newAirline7,"Airline 5 votes Airline 7", {from: newAirline5});
    }
    catch(e) {
        console.log("ERROR",e)
    }

    let airline7ConsesusResult = await config.flightSuretyData.isAirline.call(newAirline7);
    //Now consesus is made it should be registered
    assert.equal(airline7ConsesusResult, true, "There is more than 4 airlines registered");

  });

  it('(airline) cannot register an Airline using registerAirline() if it is not funded', async () => {
    
    // ARRANGE
    let newAirline = accounts[2];

    // ACT
    try {
        await config.flightSuretyApp.registerAirline(newAirline,"Airline1", {from: config.firstAirline });
    }
    catch(e) {

    }
    let result = await config.flightSuretyData.isAirline.call(newAirline); 

    // ASSERT
    assert.equal(result, false, "Airline should not be able to register another airline if it hasn't provided funding");

  });


 

});

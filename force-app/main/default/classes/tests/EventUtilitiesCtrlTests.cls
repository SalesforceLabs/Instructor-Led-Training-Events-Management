@isTest
public class EventUtilitiesCtrlTests {


    
    @isTest
    static void isEventSignUpExternalTest(){
        System.assertEquals(true, EventUtilitiesCtrl.isEventSignUpExternal('https://mydomaintest.force.com'), 'URL is not correctly verified');
    }



    @isTest
    static void isEventSignUpExternalNegativeTest(){
        System.assertEquals(false, EventUtilitiesCtrl.isEventSignUpExternal(System.URL.getOrgDomainUrl().toExternalForm()), 'URL is not correctly verified');
    }
}

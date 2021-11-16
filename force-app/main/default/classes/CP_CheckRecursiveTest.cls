/*========================================================================================================================
* @author: Kalash 
* @date: 13/08/2021
* @description: This test classes reference to CP_CheckRecursive
==========================================================================================================================*/
@isTest
public class CP_CheckRecursiveTest {
    @istest
    static void runOnceTest(){
        boolean returnedValue  = CP_CheckRecursive.runOnce();
        System.assertEquals(returnedValue, true, 'Wrong Return');
    }

}
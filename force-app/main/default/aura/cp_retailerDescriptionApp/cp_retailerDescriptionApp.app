<aura:application extends="force:slds" access="GLOBAL"  implements="forceCommunity:availableForAllPageTypes,flexipage:availableForAllPageTypes,force:hasRecordId,force:hasSObjectName">
    <aura:dependency resource="c:cp_addProperties"/>
    <!-- Create attribute to store lookup value as a sObject-->
    <aura:attribute name="selectedLookUpRecords" type="sObject[]" default="[]"/>

    <c:cp_addProperties objectAPIName="account"
                                 IconName="standard:account"
                                 lstSelectedRecords="{!v.selectedLookUpRecords}"
                                 label="Account Name"/>
    <!-- here c: is org. namespace prefix-->

</aura:application>
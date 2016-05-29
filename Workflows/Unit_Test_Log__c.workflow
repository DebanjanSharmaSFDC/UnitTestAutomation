<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Alert_for_Unit_Test_Result</fullName>
        <description>Email Alert for Unit Test Result</description>
        <protected>false</protected>
        <recipients>
            <recipient>debanjansharma.sfdc@gmail.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/UnitTestReportTemplate</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Email_Flag</fullName>
        <field>Email_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Update Email Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Send Test Resut</fullName>
        <actions>
            <name>Email_Alert_for_Unit_Test_Result</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Email_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Unit_Test_Log__c.Email_Sent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Unit_Test_Log__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>

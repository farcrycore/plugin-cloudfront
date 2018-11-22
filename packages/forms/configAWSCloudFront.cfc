<cfcomponent extends="farcry.core.packages.forms.forms" key="awscloudfront" displayname="AWS CloudFront Service" hint="AWS CloudFront Service">

	<cfproperty name="accessID" type="string" required="true" default=""
		ftSeq="1" ftWizardStep="" ftFieldset="Properties" ftLabel="Access ID">

	<cfproperty name="SecretKey" type="string" required="true" default=""
		ftSeq="2" ftWizardStep="" ftFieldset="Properties" ftLabel="Secret Key">

	<cfproperty name="wwwDistributionId" type="string" required="true" default=""
		ftSeq="3" ftWizardStep="" ftFieldset="Properties" ftLabel="Web Distribution Id" ftHint="Distribution for Web Pages">
		
	<cfproperty name="cdnDistributionId" type="string" required="true" default=""
		ftSeq="4" ftWizardStep="" ftFieldset="Properties" ftLabel="CDN Distribution Id" ftHint="Distribution for Assets">

</cfcomponent>
<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cftry>
	<cfparam name="URL.distributionId" default="">
	<cfparam name="URL.maxrows"        default="10">
	<cfparam name="URL.debug"          default="0">
	
	<cfset accessID  = application.fapi.getConfig('awscloudfront','accessID', '')>
	<cfset secretKey = application.fapi.getConfig('awscloudfront','secretKey', '')>
	
	
	<cfif accessID EQ '' OR secretKey EQ ''>
		<cfoutput><h2 style="color:red">Secret and Key not set ip</h2></cfoutput>
		<cfabort>
	</cfif>
	
	<cfset oCloudFront = application.fc.lib.cloudfront />
	<cfset stDistributions = oCloudFront.getDistributions() />

	<cfset stSiteDistribution = {}>
	<cfset stSiteDistribution[application.fapi.getConfig('awscloudfront','wwwDistributionId', 'Web')] = 'Web'>
	<cfset stSiteDistribution[application.fapi.getConfig('awscloudfront','cdnDistributionId', 'CDN')] = 'CDN'>

	<cfoutput><h1>CloudFront Distributions</h1>

	<table class="farcry-objectadmin table table-striped table-hover">
	<thead>
		<tr>
			<th>Distribution ID</th>
			<th>Farcry Name</th>
			<th>Origin Domain Names</th>
			<th>CloudFront Domain Name</th>
			<th>Actions</th>
		</tr>
	</thead>
	<tbody>
	<cfloop collection="#stDistributions#" index="id" item="stDistribution">
		<cfset farcryName = stSiteDistribution[id]?:''>

		<tr valign="top">
			<td>#id#</td>
			<td>#farcryName#</td>
			<td>
				<cfloop list="#stDistribution.OriginDomainNames#" item="OriginDomainName">#OriginDomainName#<br /></cfloop>
			</td>
			<td>#stDistribution.DomainName#</td>
			<td>
				<cfif farcryName != ''>
					<cfset urlModel = application.fapi.fixURL(addvalues='type=configAWSCloudFront&view=webtopPageModal&bodyView=webtopBodyInvalidations&distributionId=#id#&maxrows=#url.maxrows#&debug=#URL.debug#&farcryName=#farcryName#',removevalues='') />
					<a href="#urlModel#" 
					   onclick="$fc.objectAdminAction('CloudFront Invalidations for #farcryName#', this.href, { onHidden : function(){} }); return false;"
					   class="btn"  
					>Invalidations</a>
				</cfif>
			</td>
		</tr>
	</cfloop>
	</tbody>
	</table>
	</cfoutput>

	<cfcatch>
		<cfdump var="#CFCATCH#" label="ERROR" abort="YES"  />
	</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="false" />
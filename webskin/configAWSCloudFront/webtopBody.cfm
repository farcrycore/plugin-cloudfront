<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cftry>
	<cfparam name="URL.distributionId" default="">
	<cfparam name="URL.maxrows"        default="10">
	<cfparam name="URL.debug"          default="0">
	<cfparam name="URL.formName"       default="URL">

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
		<cfset distributionName = stSiteDistribution[id]?:''>

		<tr valign="top">
			<td>#id#</td>
			<td>#distributionName#</td>
			<td>
				<cfloop list="#stDistribution.OriginDomainNames#" item="OriginDomainName">#OriginDomainName#<br /></cfloop>
			</td>
			<td>#stDistribution.DomainName#</td>
			<td>
				<cfif distributionName != ''>
					<cfset urlModel = application.fapi.fixURL(addvalues='type=configAWSCloudFront&view=webtopPageModal&bodyView=webtopBodyInvalidations&distributionId=#id#&maxrows=#url.maxrows#&debug=#URL.debug#&distributionName=#distributionName#&formName=#URL.formName#',removevalues='') />
					<a href="#urlModel#" 
					   onclick="$fc.objectAdminAction('CloudFront Invalidations for #distributionName#', this.href, { onHidden : function(){} }); return false;"
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
		<cfoutput>
		<div class="alert alert-danger">
			<h3>CloudFront Error</h3>
			<p><strong>#cfcatch.message#</strong></p>
			<cfif len(cfcatch.detail)><p>#cfcatch.detail#</p></cfif>
			<hr />
			<p>Check that AWS credentials are configured via one of:</p>
			<ul>
				<li>FarCry config: <code>awscloudfront.accessID</code> / <code>awscloudfront.secretKey</code></li>
				<li>Environment variables: <code>AWS_ACCESS_KEY_ID</code> / <code>AWS_SECRET_ACCESS_KEY</code></li>
				<li>IAM role attached to the ECS task</li>
			</ul>
		</div>
		</cfoutput>
	</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="false" />
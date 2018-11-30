<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cftry>

	<cfoutput><h1>CloudFront Distributions</h1></cfoutput>

	<skin:view  typename="configAWSCloudFront" webskin="displayForm#URL.distributionName#_#URL.formName#">

	<cfoutput>
		<h3 style="color:##0e65a2"><span title="URL.maxrows=#URL.maxrows#">Last #URL.maxrows# records</span> Invalidations for #URL.distributionName#</h3>
		[ <a href="/webtop/index.cfm?#CGI.query_string#"><i class="fa fa-refresh"></i> Reload</a> |
		<cfif URL.Debug>
			<a href="/webtop/index.cfm?#Replace(CGI.query_string, 'debug=1', 'debug=0')#"><i class="fa fa-bug"></i> Turn Debug Off</a>
		<cfelse>
			<a href="/webtop/index.cfm?#Replace(CGI.query_string, 'debug=0', 'debug=1')#"><i class="fa fa-bug"></i> Turn Debug On</a>
		</cfif>
		| <a href="/webtop/index.cfm?#Replace(CGI.query_string, 'maxrows=#url.maxrows#', 'maxrows=10')#"><i class="fa fa-table"></i> 10 Rows</a>
		| <a href="/webtop/index.cfm?#Replace(CGI.query_string, 'maxrows=#url.maxrows#', 'maxrows=50')#"><i class="fa fa-table"></i> 50 Rows</a>
		| <a href="/webtop/index.cfm?#Replace(CGI.query_string, 'maxrows=#url.maxrows#', 'maxrows=100')#"><i class="fa fa-table"></i> 100 Rows</a>
		]
	</cfoutput>
	<skin:view  typename="configAWSCloudFront" webskin="displayInvalidations">

	<cfcatch>
		<cfdump var="#CFCATCH#" label="ERROR" abort="YES"  />
	</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="false" />
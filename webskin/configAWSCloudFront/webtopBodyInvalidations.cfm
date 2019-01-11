<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cftry>

	<cfoutput><h1>CloudFront Distributions</h1></cfoutput>

	<skin:view  typename="configAWSCloudFront" webskin="displayForm#URL.distributionName#_#URL.formName#">

	<cfset urlAjaxReload = "/webtop/index.cfm?#CGI.query_string#">
	<cfset urlAjaxReload = ReplaceNoCase(urlAjaxReload, '&view=webtopPageModal', '&view=displayInvalidations')>
	<cfset urlAjaxReload = ReplaceNoCase(urlAjaxReload, 'bodyView=webtopBodyInvalidations', '')>
	
	<cfoutput>
		<h3 style="color:##0e65a2"><span title="URL.maxrows=#URL.maxrows#">Last #URL.maxrows# records</span> Invalidations for #URL.distributionName#</h3>
		[ <a href="#CGI.query_string#" class="linkReload"><i class="fa fa-refresh"></i> Reload</a> |
		<cfif URL.Debug>
			<a href="#Replace(urlAjaxReload, 'debug=1', 'debug=0')#" class="linkReload"><i class="fa fa-bug"></i> Turn Debug Off</a>
		<cfelse>
			<a href="#Replace(urlAjaxReload, 'debug=0', 'debug=1')#" class="linkReload"><i class="fa fa-bug"></i> Turn Debug On</a>
		</cfif>
		| <a href="#Replace(urlAjaxReload, 'maxrows=#url.maxrows#', 'maxrows=10')#" class="linkReload"><i class="fa fa-table"></i> 10 Rows</a>
		| <a href="#Replace(urlAjaxReload, 'maxrows=#url.maxrows#', 'maxrows=50')#" class="linkReload"><i class="fa fa-table"></i> 50 Rows</a>
		| <a href="#Replace(urlAjaxReload, 'maxrows=#url.maxrows#', 'maxrows=100')#" class="linkReload"><i class="fa fa-table"></i> 100 Rows</a>
		]
	</cfoutput>
	
	<cfoutput><div id="displayInvalidations"></cfoutput>
	<skin:view  typename="configAWSCloudFront" webskin="displayInvalidations">
	<cfoutput></div></cfoutput>

	<skin:onReady><script type="text/javascript"><cfoutput>
		
		$j(".linkReload").bind("click",function(){

			$j("##displayInvalidations").html('<p>reloading ...<p>');
			$j.ajax({
				url			: $j(this).attr('href'),
				type		: "GET",
				success		: function(data) {
								$j("##displayInvalidations").html(data);
							  },
				dataType	: "HTML"
			});
		return false;
		});
	</cfoutput></script></skin:onReady>

	<cfcatch>
		<cfdump var="#CFCATCH#" label="ERROR" abort="YES"  />
	</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="false" />
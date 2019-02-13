<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cftry>

	<cfoutput><h1>CloudFront Distributions</h1></cfoutput>

	<skin:view  typename="configAWSCloudFront" webskin="displayForm#URL.distributionName#_#URL.formName#">

	<cfset urlAjaxReload = "/webtop/index.cfm?#CGI.query_string#">
	<cfset urlAjaxReload = ReplaceNoCase(urlAjaxReload, '&view=webtopPageModal', '&view=displayInvalidations')>
	<cfset urlAjaxReload = ReplaceNoCase(urlAjaxReload, 'bodyView=webtopBodyInvalidations', '')>
	
	<cfoutput>
		<h3 style="color:##0e65a2"><span id="headerInvalidations">Last #URL.maxrows# records</span> Invalidations for #URL.distributionName#</h3>
		[ <a href="#urlAjaxReload#" data-maxrows="#url.maxrows#" class="linkReload" id="reloadInvalidations"><i class="fa fa-refresh"></i> Reload</a>
		| <a href="#urlAjaxReload#" data-maxrows="10"  class="linkReload"><i class="fa fa-table"></i> 10 Rows</a>
		| <a href="#urlAjaxReload#" data-maxrows="50"  class="linkReload"><i class="fa fa-table"></i> 50 Rows</a>
		| <a href="#urlAjaxReload#" data-maxrows="100" class="linkReload"><i class="fa fa-table"></i> 100 Rows</a>
		]
	</cfoutput>
	
	<cfoutput><div id="displayInvalidations"></cfoutput>
	<skin:view  typename="configAWSCloudFront" webskin="displayInvalidations">
	<cfoutput></div></cfoutput>

	<skin:onReady><script type="text/javascript"><cfoutput>
		
		$j(".linkReload").bind("click",function(){
			var maxrows = $j(this).attr('data-maxrows');
			
			$j("##reloadInvalidations").attr('data-maxrows', maxrows);
			
			$j("##headerInvalidations").html('Last ' + maxrows + ' records');
		
			var urlInvalidations = $j(this).attr('href').replace("maxrows=#url.maxrows#", "maxrows=" + maxrows);

			$j("##displayInvalidations").html('<p>reloading ...<p>');
			$j.ajax({
				url			: urlInvalidations,
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
component displayname="AWS CloudFront Library" {

		public array function getInvalidates(
			string distributionName="",
			string distributionId="",
			number maxrows=20
		) {
			//var accessID       = application.fapi.getConfig('awscloudfront','accessID');
			//var secretKey      = application.fapi.getConfig('awscloudfront','secretKey');
			var distributionId = getDistributionId(ARGUMENTS.distributionName, ARGUMENTS.distributionId);
			
			//var awsCredentials    = createObject("java", 'com.amazonaws.auth.BasicAWSCredentials').init(accessID,secretKey);
			//var cloudFrontService = createobject("java","com.amazonaws.services.cloudfront.AmazonCloudFrontClient").init( awsCredentials);
			var cloudFrontService =  getClient();
			
			try {
				var aResults = [];
				var ListInvalidationsRequest = createobject("java","com.amazonaws.services.cloudfront.model.ListInvalidationsRequest").init();
				ListInvalidationsRequest.setdistributionId(distributionId);
				
				var listInvalidations = cloudFrontService.listInvalidations(ListInvalidationsRequest);
				
				var InvalidationRequest = createobject("java","com.amazonaws.services.cloudfront.model.GetInvalidationRequest").init();
				
				var aInvalidationList = listInvalidations.getInvalidationList().getItems();
	// aInvalidationList.slice( offset=0, arguments.maxrows )
				for( var i in aInvalidationList) {
					InvalidationRequest.setId(i.getId());
					InvalidationRequest.setdistributionId(distributionId);
					var Invalidation = cloudFrontService.getInvalidation(InvalidationRequest);
				
					aResults.append({"InvalidationId": i.getId(), "CreateTime": i.getCreateTime(), "Status": i.getStatus(), "Path": Invalidation.getInvalidation().getInvalidationBatch().getPaths().getItems()[1]})
				
					if (aResults.len() == arguments.maxrows) break;
				}
					
			} catch (any error) {
				dump(var=distributionId, label="listInvalidations: no invalitions for this distribution");
				dump(var=error, label="Error", abort=true);
			}
			
			return aResults
		}	
		
	    public struct function invalidatePath(
	    	required string file,
	    	string distributionName="",
			string distributionId="",
	    ) {
	    	var stReturn = {};
			var distributionId = getDistributionId(ARGUMENTS.distributionName, ARGUMENTS.distributionId);

			stReturn['arguments']      = arguments;
			stReturn['distributionId'] = distributionId;
			
	        var cloudFrontService          = getClient();
	        var paths                      = createobject("java","com.amazonaws.services.cloudfront.model.Paths").init();
	        var invalidationBatch          = createobject("java", "com.amazonaws.services.cloudfront.model.InvalidationBatch").init();
	        var createInvalidationRequest  = createobject("java","com.amazonaws.services.cloudfront.model.CreateInvalidationRequest").init();
	        var createInvalidationResponse = "";
	        var CallerReference            = CreateUUID();
	
	        paths.setItems([ arguments.file ]);
	        paths.setQuantity(1);
	        invalidationBatch.setPaths(paths);
	        invalidationBatch.setCallerReference(CallerReference);
	        createInvalidationRequest.setdistributionId(distributionId);
	        createInvalidationRequest.setInvalidationBatch(invalidationBatch);
	
	        try {
	            createInvalidationResponse = cloudFrontService.createInvalidation(createInvalidationRequest);
	
	            stReturn['InvalidationId'] = createInvalidationResponse.getInvalidation().getId();
	            stReturn['Status'] = createInvalidationResponse.getInvalidation().getStatus();
	
	            stReturn['CallerReference'] = CallerReference
	            stReturn['success'] = true;
	            stReturn['message'] = "Submitted to CloudFront"
	        }
	        catch (com.amazonaws.services.cloudfront.model.TooManyInvalidationsInProgressException error){
	            stReturn['error']   = error;
	            stReturn['success'] = false;
	            stReturn['message'] = "Too Many Invalidations In Progress";
	        }
	        catch (any error) {
	        	stReturn['error']   = error;
	        	stReturn['success'] = false;
	        	stReturn['message'] = "#error.Message#. #error.Detail#";
	        }
	
	        return stReturn;
	    }
	
		public struct function getDistributions(){
			
			var stDistributions = {};
			var stDistribution = {};
			var aOrigins       = [];
			var stOrigin       = {};
			
			var cloudFrontService =  getClient();
	
			var ListDistributionsRequest = createobject("java","com.amazonaws.services.cloudfront.model.ListDistributionsRequest").init();
			var ListDistributionsResult = cloudFrontService.listDistributions(ListDistributionsRequest);
			var aDistributions = ListDistributionsResult.getDistributionList().getItems();
			
			for (stDistribution in aDistributions) {
		
			stDistributions[stDistribution.getId()] = {};
			stDistributions[stDistribution.getId()]['DomainName'] = stDistribution.getDomainName();
			stDistributions[stDistribution.getId()]['OriginDomainNames'] = '';
			
			aOrigins = stDistribution.getOrigins().getItems();
			for (stOrigin in aOrigins) {
				stDistributions[stDistribution.getId()]['OriginDomainNames'] = ListAppend(stDistributions[stDistribution.getId()]['OriginDomainNames'], stOrigin.getDomainName());
			}
	
	}
			return stDistributions;
			
		}
		
	public struct function getInvalidateById(
		required string InvalidationId,
		string distributionName="",
		string distributionId="",
	) {
			var status = '#arguments.InvalidationId# not found';
			
			var accessID       = application.fapi.getConfig('awscloudfront','accessID');
			var secretKey      = application.fapi.getConfig('awscloudfront','secretKey');
			var distributionId = getDistributionId(ARGUMENTS.distributionName, ARGUMENTS.distributionId);

		try {
			var cloudFrontService = getClient();
			
			var InvalidationRequest = createobject("java","com.amazonaws.services.cloudfront.model.GetInvalidationRequest").init();
			InvalidationRequest.setId(arguments.InvalidationId);
			InvalidationRequest.setDistributionId(distributionId);
			
			var invalidation = cloudFrontService.getInvalidation(InvalidationRequest);
			var i = invalidation.getInvalidation();
			var stResult = {"InvalidationId": i.getId(), "CreateTime": i.getCreateTime(), "Status": i.getStatus(), "Path": i.getInvalidationBatch().getPaths().getItems()[1]};

				
		} catch (any error) {
			dump(var=arguments, label="getInvalidateStatus: no invalitions for this distribution");
			dump(var=error, label="Error", abort=true);
		}
		
		return stResult
	}	
	
	
    private any function getClient(){
		var accessID  = application.fapi.getConfig('awscloudfront','accessID');
		var secretKey = application.fapi.getConfig('awscloudfront','secretKey');
		
		var credentials            = createobject("java","com.amazonaws.auth.BasicAWSCredentials").init(accessID, secretKey);
		var AmazonCloudFrontClient = createobject("java","com.amazonaws.services.cloudfront.AmazonCloudFrontClient").init(credentials);
	
		return AmazonCloudFrontClient;

    }
    
	private string function getDistributionId(
		string distributionName="",
		string distributionId=""
	) {
	
		if (ARGUMENTS.distributionId != '')
			distributionId = ARGUMENTS.distributionId;
		else if (ARGUMENTS.distributionName == 'WEB') {
			distributionId = application.fapi.getConfig('awscloudfront','webDistributionId', '');
			if (distributionId == "") {
				throw(type='cloudfront.getDistributionId.webDistributionId', message="Web Distribution Id has not been set", detail="Set value in Configuration 'AWS CloudFront Service' ");
			}
		} else if (ARGUMENTS.distributionName == 'CDN') {
			distributionId = application.fapi.getConfig('awscloudfront','cdnDistributionId', '');
			if (distributionId == "") {
				throw(type='cloudfront.getDistributionId.cdnDistributionId', message="CDN Distribution Id has not been set", detail="Set value in Configuration 'AWS CloudFront Service' ");
			}
		} else {
			throw(type='cloudfront.getDistributionId.distribution', message="Distribution must be Distibution ID or Name [WEB|CDN]", detail="distributionId='#ARGUMENTS.distribution#'. distributionName='#ARGUMENTS.distributionName#'");
		}	
		return distributionId;

	}
}
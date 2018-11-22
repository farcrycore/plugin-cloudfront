component displayname="AWS CloudFront Library" {

    	
	public array function getInvalidates(
		string distributionName="",
		string distributionId="",
		number maxrows=20
	) {
		var accessID       = application.fapi.getConfig('awscloudfront','accessID');
		var secretKey      = application.fapi.getConfig('awscloudfront','secretKey');
		var distributionId = '';
		
		var awsCredentials    = createObject("java", 'com.amazonaws.auth.BasicAWSCredentials').init(accessID,secretKey);
		var cloudFrontService = createobject("java","com.amazonaws.services.cloudfront.AmazonCloudFrontClient").init( awsCredentials);

		if (ARGUMENTS.distributionId != '')
			distributionId = ARGUMENTS.distributionId;
		else if (ARGUMENTS.distributionName == 'WEB') {
			distributionId = application.fapi.getConfig('awscloudfront','webDistributionId');
		} else if (ARGUMENTS.distributionName == 'CDN') {
			distributionId = application.fapi.getConfig('awscloudfront','cdnDistributionId');
		} else {
			throw(type='cloudfront.getInvalidates.distribution', message="Distribution must be Distibution ID or Name [WEB|CDN]", detail="distributionId='#ARGUMENTS.distribution#'. distributionName='#ARGUMENTS.distributionName#'");
		}
		
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
			
				aResults.append({"Id": i.getId(), "CreateTime": i.getCreateTime(), "Status": i.getStatus(), "Path": Invalidation.getInvalidation().getInvalidationBatch().getPaths().getItems()[1]})
			
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
		var distributionId = '';

		
		stReturn['arguments'] = arguments;

		if (ARGUMENTS.distributionId != '')
			distributionId = ARGUMENTS.distributionId;
		else if (ARGUMENTS.distributionName == 'WEB') {
			distributionId = application.fapi.getConfig('awscloudfront','webDistributionId');
		} else if (ARGUMENTS.distributionName == 'CDN') {
			distributionId = application.fapi.getConfig('awscloudfront','cdnDistributionId');
		} else {
			throw(type='cloudfront.getInvalidates.distribution',message="Distribution must be Distibution ID or Name [WEB|CDN]", detail="distributionId='#ARGUMENTS.distribution#'. distributionName='#ARGUMENTS.distributionName#'");
		}

		stReturn['distributionId'] = distributionId;
		
        var cfClient                   = getClient();
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
            createInvalidationResponse = cfClient.createInvalidation(createInvalidationRequest);

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
		
		// var accessID       = application.fapi.getConfig('awscloudfront','accessID');
		// var secretKey      = application.fapi.getConfig('awscloudfront','secretKey');
		// var awsCredentials = createObject("java", 'com.amazonaws.auth.BasicAWSCredentials').init(accessID,secretKey);
		// var cloudFrontService =  createobject("java","com.amazonaws.services.cloudfront.AmazonCloudFrontClient").init( awsCredentials);
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
	
    public any function getClient(){
		var accessID  = application.fapi.getConfig('awscloudfront','accessID');
		var secretKey = application.fapi.getConfig('awscloudfront','secretKey');
		 
		//writeLog(file="CloudFront",text="Starting CloudFront client");
		
		var credentials = createobject("java","com.amazonaws.auth.BasicAWSCredentials").init(accessID, secretKey);
		var tmpClient = createobject("java","com.amazonaws.services.cloudfront.AmazonCloudFrontClient").init(credentials);
		
		return tmpClient;
    }
}
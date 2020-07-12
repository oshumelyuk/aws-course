echo "Starting script..."
echo "Checking S3 bucket exists..."                                                                                                                                                                                                           
BUCKET_NAME=ac-buk                                                                                                                                                                                                                         
S3_CHECK=$(aws s3 ls "s3://${BUCKET_NAME}" 2>&1)                                                                                                                                                 

#Some sort of error happened with s3 check                                                                                                                                                                                                    
if [ $? != 0 ]                                                                                                                                                                                                                                
then                                                                                                                                                                                                                                          
  NO_BUCKET_CHECK=$(echo $S3_CHECK | grep -c 'NoSuchBucket')                                                                                                                                                                                     
  if [ $NO_BUCKET_CHECK = 1 ]; then   
    aws s3 mb s3://$BUCKET_NAME                                                                                                                                                                                                         
  else                                                                                                                                                                                                                                        
    echo "Error checking S3 Bucket"                                                                                                                                                                                                           
    echo "$S3_CHECK"                                                                                                                                                                                                                          
    exit 1                                                                                                                                                                                                                                    
  fi 
else                                                                                                                                                                                                                                         
  echo "Bucket exists"
fi    

echo "Add versioning.."
aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled

echo "Uploading files..."
aws s3 cp persist3-0.0.1-SNAPSHOT.jar s3://$BUCKET_NAME/persist3-0.0.1-SNAPSHOT.jar
aws s3 cp calc-0.0.1-SNAPSHOT.jar s3://$BUCKET_NAME/calc-0.0.1-SNAPSHOT.jar
aws s3 cp calc-client-1.0-SNAPSHOT-jar-with-dependencies.jar s3://$BUCKET_NAME/calc-client-1.0-SNAPSHOT-jar-with-dependencies.jar
echo "Completed"
echo "Starting script..."
echo This is simple text file > aws-3.txt
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
aws s3 cp aws-3.txt s3://$BUCKET_NAME/aws-s3.txt
echo "Completed"
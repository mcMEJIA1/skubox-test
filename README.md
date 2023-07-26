to use this Tf stack:
 1. Add AWS credentials configuration to local environment 
 2. Setup the desired number of nodes changin the servers_number variable value (2 as default)
 3. execute terraform init/plan/apply commands or use the stack.sh file

 -- to use thethe script you need pass the desired option ./stack.sh install|run|destroy|status

This terraform Stck will creates the following resources
 1. VPC
 2. Subnet
 3. Security group
 4. desired numbers of ec2 instances
 5. An Application load balancer
 6. Load balancer attachments
 7. Load balancer listener 
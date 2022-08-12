module "network" {
  source = "./network"
  project_id = var.project_id
  vpc_name  = "mynetwork"
  subnet_name = "mysubnet"
  subnet_cidr = "10.0.0.0/16"
  subnet_region = "us-central1"
}
# module "dataset_one" {
#   source = "./big-query"
#   project_id = var.project_id
#   name  = "dataset_one"
#   location = "us-central1"
#   id = "dataset_one_abdo"
#   user_by_email = module.sa-bq-reader-writer.sa-email
#   role = "OWNER"
# }
# module "dataset_two" {
#   source = "./big-query"
#   project_id = var.project_id
#   name  = "dataset_two"
#   location = "us-central1"
#   id = "dataset_two_abdo"
#   user_by_email = module.sa-bq-reader-writer.sa-email
#   role = "OWNER"
# }
# module "dataset_three" {
#   source = "./big-query"
#   project_id = var.project_id
#   name  = "dataset_three"
#   location = "us-central1"
#   id = "dataset_three_abdo"
#   user_by_email = module.sa-bq-reader-writer.sa-email
#   role = "OWNER"
# }
# module "bucket_one" {
#   source = "./bucket"
#   project_id = var.project_id
#   name  = var.bucket_one
#   location = "us-central1"
#   storage_class = "STANDARD"
# }
# module "bucket_two" {
#   source = "./bucket"
#   project_id = var.project_id
#   name  = var.bucket_two
#   location = "us-central1"
#   storage_class = "STANDARD"
# }

# module "bucket_three" {
#   source = "./bucket"
#   project_id = var.project_id
#   name  = var.bucket_three
#   location = "us-central1"
#   storage_class = "STANDARD"
# }
# module "bucket-policy-one" {
#   source = "./bucket-policy"
#   bucket = var.bucket_one
#   role = "roles/storage.objectViewer"
#   members = ["serviceAccount:${module.sa-buckets-reader.sa-email}"]
# }
# module "bucket-policy-two" {
#   source = "./bucket-policy"
#   bucket = var.bucket_two
#   role = "roles/storage.objectViewer"
#   members = ["serviceAccount:${module.sa-buckets-reader.sa-email}"]
# }
# module "bucket-policy-three" {
#   source = "./bucket-policy"
#   bucket = var.bucket_three
#   role = "roles/storage.objectViewer"
#   members = ["serviceAccount:${module.sa-buckets-reader.sa-email}"]
# }
module "vm" {
  source = "./compute_machine"
  project_id = var.project_id
  region = "us-central1"
  zone = "a"
  os_image = "centos-cloud/centos-7"
  #os_image = "cos-cloud/cos-stable"
  machine_name = "vm"
  machine_type = "e2-micro"
  boot_disk_size = "20"
  vpc_name = module.network.vpc_name
  subnet_name = module.network.subnet_name
  sa-email = module.sa-buckets-reader.sa-email
  startup-script = <<EOT
#!/bin/bash
sudo yum install kubectl -y
sudo yum install google-cloud-sdk-gke-gcloud-auth-plugin -y
echo "USE_GKE_GCLOUD_AUTH_PLUGIN=True" >> ~/.bashrc 
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine -y
sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo systemctl start docker
sudo usermod -aG docker abdurrhman
sudo -i
gcloud auth configure-docker
EOT
}

module "sa-buckets-reader" {
  source = "./service_account"
  project_id = var.project_id
  name  = "sa-buckets-reader"
  id = "sa-buckets-reader"
}
module "sa-bq-reader-writer" {
  source = "./service_account"
  project_id = var.project_id
  name  = "sa-bq-reader-writer"
  id = "sa-bq-reader-writer"
}
module "sa-gcr-reader" {
  source = "./service_account"
  project_id = var.project_id
  name  = "sa-gcr-reader"
  id = "sa-gcr-reader"
}
module "gcr-binding" {
  project_id = var.project_id
  source = "./iam-binding"
  role = "roles/storage.objectViewer"
  members = ["serviceAccount:${module.sa-gcr-reader.sa-email}"]
}
module "gke-access-role-to-get-credential" {
  source = "./iam-role"
  id = "gkeCredentialRole"
  title = "GKE credential role"
  project_id = var.project_id
  permissions = [
    "container.apiServices.get",
    "container.apiServices.list",
    "container.clusters.get",
    "container.clusters.getCredentials",
    "container.clusters.impersonate",
  ]
}
module "name" {
  source = "./gke"
  cluster-name = "mycluster"
  node-count = 1
  node-machine-type = "e2-standard-2"
  #node-machine-type = "e2-micro"
  region = "us-central1"
  zone_one =  "c"
  zone_two = "f"
  subnet_name = module.network.subnet_name
  vpc_id = module.network.vpc_id
  master_ipv4_cidr_block = "172.16.0.0/28"
  pods_ipv4_cidr_block = "172.17.0.0/16"
  services_ipv4_cidr_block = "192.168.0.0/16"
  node_boot_disk_size = 30
  node_boot_disk_type = "pd-standard"
  os_image = "COS_CONTAINERD"
  authorized-network-cidr = module.network.subnet_cidr
  service-account-email = module.sa-gcr-reader.sa-email
}
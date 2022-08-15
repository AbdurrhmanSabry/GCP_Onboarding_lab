module "network" {
  source = "./network"
  project_id = var.project_id
  vpc_name  = "mynetwork"
  subnet_name = "mysubnet"
  subnet_cidr = "10.0.0.0/16"
  subnet_region = "us-central1"
}
module "datasets" {
  source = "./BigQuery"
  project_id = var.project_id
  datasets = {
    "dataset_one" = {
      id = "dataset_one_abdo"
      location = "us-central1"
      name = "dataset_one"
      user_by_email = "${module.sa.sa-email[1]}"
      role = "OWNER"
    },"dataset_two" = {
      id = "dataset_two_abdo"
      location = "us-central1"
      name = "dataset_two"
      user_by_email = "${module.sa.sa-email[1]}"
      role = "OWNER"
    },
    "dataset_three" = {
      id = "dataset_three_abdo"
      location = "us-central1"
      name = "dataset_three"
      user_by_email = "${module.sa.sa-email[1]}"
      role = "OWNER"
    }
  }
}
# module "datasets-members" {
#     source = "./BigQuery-member"
#     project_id = var.project_id
#     bq-members = {
#       "one" = {
#         dataset_id = module.datasets.datasets_info.dataset_one.id
#         member = "serviceAccount:${module.sa.sa-email[1]}"
#         role = "roles/bigquery.dataEditor"
#       },
#       "two" = {
#         dataset_id = module.datasets.datasets_info.dataset_two.id
#         member = "serviceAccount:${module.sa.sa-email[1]}"
#         role = "roles/bigquery.dataEditor"
#       },
#       "three" = {
#         dataset_id = module.datasets.datasets_info.dataset_three.id
#         member = "serviceAccount:${module.sa.sa-email[1]}"
#         role = "roles/bigquery.dataEditor"
#       }
#     }
#     depends_on = [
#       module.datasets
#     ]
# }
module "buckets" {
  source = "./bucket"
  project_id = var.project_id
  buckets_info = {
    "bucket_one" = {
      location = "us-central1"
      name = var.bucket_one
    },
    "bucket_two" = {
      location = "us-central1"
      name = var.bucket_two
    },
    "bucket_three" = {
      location = "us-central1"
      name = var.bucket_three
    }
  }
}
module "bucket-members" {
  source = "./bucket-member"
  bucket_members = {
    "one" = {
      bucket = module.buckets.buckets_info.bucket_one.name
      member =  "serviceAccount:${module.sa.sa-email[0]}"
      role = "roles/storage.objectViewer"
    },
    "two" = {
      bucket = module.buckets.buckets_info.bucket_two.name
      member =  "serviceAccount:${module.sa.sa-email[0]}"
      role = "roles/storage.objectViewer"
    }, "three" = {
      bucket = module.buckets.buckets_info.bucket_three.name
      member =  "serviceAccount:${module.sa.sa-email[0]}"
      role = "roles/storage.objectViewer"
    }
  }
  depends_on = [
    module.buckets
  ]
}
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
  sa-email = module.sa.sa-email[0]
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

  depends_on = [
    module.network, module.sa 
  ]
}

module "sa" {
  source = "./service_account"
  project_id = var.project_id
  ids = [ "sa-buckets-reader" , "sa-bq-reader-writer" , "sa-gcr-reader"]
  names =[ "sa-buckets-reader", "sa-bq-reader-writer" , "sa-gcr-reader" ]
}
module "iam_member" {
  project_id = var.project_id
  source = "./iam-member"
  iam_members = {
    "sa-objectViewer" = {
      member = "serviceAccount:${module.sa.sa-email[2]}"
      role = "roles/storage.objectViewer"
    }
  }
  depends_on = [
    module.sa
  ]
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
  node-count = 0
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
  service-account-email = module.sa.sa-email[2]
}
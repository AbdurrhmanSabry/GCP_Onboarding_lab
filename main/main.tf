module "network" {
  source = "../modules/network"
  vpcs = {
    "vpc_one" = {
      auto_create_subnetworks = false
      mtu = 1460
      project_id = var.project_id
      routing_mode = "GLOBAL"
      vpc_name = "mynetwork"
    }
  }
  subnets = {
    "mysubnet" = {
      private_ip_google_access = true
      subnet_cidr = "10.0.0.0/16"
      subnet_region = "us-central1"
    }
  }
}

module "vm" {
  source = "../modules/compute_machine"
  compute_machines = {
    "vm1" = {
      machine_name = "vm1"
      machine_type = "e2-micro"
      os_image = "centos-cloud/centos-7"
      #os_image = "cos-cloud/cos-stable"
      project_id = var.project_id
      sa_email = module.sa.sa-email[0]
      subnet_name = module.network.subnet_details.vpc_one-mysubnet.name
      vm_location = "us-central1-a"
      boot_disk_size = "20"
      vpc_name = module.network.vpc_details.vpc_one.name
      tags = ["vm1"]
      scopes = ["cloud-platform"]
      startup_script = <<EOT
      #!/bin/bash
      sudo yum install google-cloud-sdk-gke-gcloud-auth-plugin -y
      echo "USE_GKE_GCLOUD_AUTH_PLUGIN=True" >> ~/.bashrc 
      gcloud auth configure-docker
      EOT
    }
  }
  depends_on = [
    module.network, module.sa 
  ]
}
module "GKE" {
  source = "../modules/gke"
  clusters = {
    "mycluster" = {
      authorized_networks = {
        "authorized_one" = {
          cidr_block = module.network.subnet_details.vpc_one-mysubnet.ip_cidr_range
          display_name = "authorized-one"
        },
        "authorized_two" = {
          cidr_block = "102.47.26.21/32"
          display_name = "authorized-two"
        }
      }
      cluster_ipv4_cidr_block = "172.17.0.0/16"
      cluster_location = "us-central1-c"
      cluster_name = "mycluster"
      enable_cluster_autoscaling = false
      enable_master_global_access_config = true
      enable_network_policy = true
      enable_private_endpoint = false
      enable_private_nodes = true
      initial_node_count = 1
      master_ipv4_cidr_block = "172.16.0.0/28"
      networking_mode = "VPC_NATIVE"
      release_channel = "STABLE"
      remove_default_node_pool = true
      services_ipv4_cidr_block = "192.168.0.0/16"
      subnet_name = module.network.subnet_details.vpc_one-mysubnet.name
      vpc_id = module.network.vpc_details.vpc_one.id
    }
  }
  node_pools = {
    "pool" = {
      auto_repair = true
      auto_upgrade = true
      max_surge = 1
      max_unavailable = 0
      node_config = {
        disk_size_gb = 30
        disk_type = "pd-standard"
        image_type = "COS_CONTAINERD"
        machine_type = "e2-standard-2"
        oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
        service_account = module.sa.sa-email[2]
      }
      node_count = 1
      node_locations = [ "us-central1-c", "us-central1-f" ]
    }
  }
  depends_on = [
    module.network
  ]  
}

module "sa" {
  source = "../modules/service_account"
  project_id = var.project_id
  ids = [ "sa-buckets-reader" , "sa-bq-reader-writer" , "sa-gcr-reader"]
  names =[ "sa-buckets-reader", "sa-bq-reader-writer" , "sa-gcr-reader" ]
}
module "iam_member" {
  project_id = var.project_id
  source = "../modules/iam-member"
  iam_members = {
    "sa-objectViewer" = {
      member = "serviceAccount:${module.sa.sa-email[2]}"
      role = "roles/storage.objectViewer"
    },
    "container-admin" = {
      member = "serviceAccount:${module.sa.sa-email[2]}"
      role = "roles/container.admin"
    }
  }
  depends_on = [
    module.sa
  ]
}


module "datasets" {
  source = "../modules/BigQuery"
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

module "buckets" {
  source = "../modules/bucket"
  buckets_info = {
    "bucket_one" = {
      location = "us-central1"
      name = var.bucket_one
      project_id = var.project_id
    },
    "bucket_two" = {
      location = "us-central1"
      name = var.bucket_two
      project_id = var.project_id
    },
    "bucket_three" = {
      location = "us-central1"
      name = var.bucket_three
      project_id = var.project_id
    }
  }
}
module "bucket-members" {
  source = "../modules/bucket-member"
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


module "gke-access-role-to-get-credential" {
  source = "../modules/iam-role"
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

# module "nat" {
#   source = "../modules/nat"
#   nat_details = {
#     "nat_one" = {
#       nat_ip_allocate_option = "AUTO_ONLY"
#       nat_name = "my-nat"
#       project_id = var.project_id
#       source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
#       source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
#     }
#   }
#   routers = {
#     "router_one" = {
#       bgp_asn = 64514
#       subnet_name = module.network.subnet_details.vpc_one-mysubnet.name
#       subnet_region =  module.network.subnet_details.vpc_one-mysubnet.region
#       vpc_id = module.network.vpc_details.vpc_one.id
#     }
#   }
#   depends_on = [
#     module.network
#   ]
# }
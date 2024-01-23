# Generate random resource group name
resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

resource "random_pet" "azurerm_kubernetes_cluster_name" {
  prefix = "cluster"
}

resource "random_pet" "azurerm_kubernetes_cluster_dns_prefix" {
  prefix = "dns"
}

provider "azurerm" {
  features {}
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = random_pet.azurerm_kubernetes_cluster_name.id
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = random_pet.azurerm_kubernetes_cluster_dns_prefix.id

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = var.node_count
  }
  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }
  role_based_access_control_enabled = true

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}

##### k8s resources #####
resource "kubernetes_deployment" "bitcoin-tracker" {
  metadata {
    name = "bitcoin-tracker"
    labels = {
      App = "bitcoinTracker"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "bitcoinTracker"
      }
    }
    template {
      metadata {
        labels = {
          App = "bitcoinTracker"
        }
      }
      spec {
        container {
          image = "omerregistery1.azurecr.io/bitcoin-tracker:v1.0.2"
          name  = "bitcoin-tracker"

          port {
            container_port = 3000
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "service_a" {
  metadata {
    name = "service-a"
  }

  spec {
    selector = {
      app = "service-a"
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 3000
    }
  }
}

resource "kubernetes_service" "service_b" {
  metadata {
    name = "service-b"
  }

  spec {
    selector = {
      app = "service-b"
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 8080
    }
  }
}

resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name = "ingress"
  }

  spec {
    default_backend {
      service {
        name = "service-a"
        port {
          number = 3000
        }
      }
    }

    rule {
      host = "dns-knowing-quail-3mffkysz.hcp.eastus.azmk8s.io"
      http {
        path {
          backend {
            service {
              name = "service-a"
              port {
                number = 3000
              }
            }
          }

          path = "/service-A"
        }

        path {
          backend {
            service {
              name = "service-b"
              port {
                number = 8080
              }
            }
          }

          path = "/service-B"
        }
      }
    }
  }
}

resource "kubernetes_network_policy" "service_a" {
  metadata {
    name = "service-a-policy"
  }

  spec {
    pod_selector {
      match_labels = {
        app = "service-a"
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "service_b" {
  metadata {
    name = "service-b-policy"
  }

  spec {
    pod_selector {
      match_labels = {
        app = "service-b"
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "azurerm_monitor_autoscale_setting" "onica-azure-autoscaling" {
  name                = "onica-azure-autoscaling"
  location            = "Canada Central"
  resource_group_name = azurerm_resource_group.onica-rg.name
  target_resource_id  = azurerm_virtual_machine_scale_set.onica-vmss.id

  profile {
    name = "onica-azure-profile"
    capacity {
      default = 2
      minimum = 2
      maximum = 4
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_virtual_machine_scale_set.onica-vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 40
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_virtual_machine_scale_set.onica-vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 10
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}

resource "random_password" "password" {
  length           = 10
  special          = true
  override_special = "_%@"
}

resource "azurerm_virtual_machine_scale_set" "onica-vmss" {
  name                = "onica-azure-scaleset1"
  location            = "Canada Central"
  resource_group_name = azurerm_resource_group.onica-rg.name

  #automatic_os_upgrade = true
  upgrade_policy_mode = "Manual"
  #health_probe_id = azurerm_lb_probe.onica-lb-probe.id

  zones = [1, 2, 3]

  sku {
    name     = "Standard_A1_v2"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "onica-azure-instance"
    admin_username       = "onicaadmin"
    admin_password       = random_password.password.result
    custom_data          = <<-EOF
      #!/bin/bash
      apt-get update
      apt-get install -y nginx
      systemctl enable nginx
      echo "Hello World! From $HOSTNAME" > /var/www/html/index.nginx-debian.html
      systemctl restart nginx
      EOF
  }

  network_profile {
    name                      = "onica-azure-network-profile"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.onica-nsg.id

    ip_configuration {
      name                                   = "onica-instance"
      primary                                = true
      subnet_id                              = azurerm_subnet.onica-private-subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.lbnatpool.id]
    }
  }
}

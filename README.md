# sm200-nginx-cert-valid-test
Skills map 200 Terraform - create fqdn dns entry and get a valid ssl cert - configure a nginx web, test certificate works - padlock closes

# Purpose
We aiming to create FQDN dns entry and get a valid ssl cert applied in running Nginx server machine, the test wit closed padlock in browser should pass. 

# Walkthrough

- Register and export as env variables GoDaddy API keys. 
    - Use this link : https://developer.godaddy.com/keys/ ( pay attention that you are creating API KEY IN **production** area)
    - Export them via : 
    ```bash
    export GODADDY_API_KEY=MY_KEY
    export GODADDY_API_SECRET=MY_SECRET
    ```
- Install GoDaddy plugin :  https://github.com/n3integration/terraform-godaddy
    - Run : 
    ```bash 
    bash <(curl -s https://raw.githubusercontent.com/n3integration/terraform-godaddy/master/install.sh)
    ```
    - This is going to create plugin binary in `~/.terraform/plugins` , while the recommended path should be `~/.terraform.d/plugins/`, and the name should be in a proper format pattern . let's move and rename it : 
    ```bash
    mv ~/.terraform/plugins/terraform-godaddy ~/.terraform.d/plugins/terraform-provider-godaddy
    ```
- Terraform code to create record : 
    - [main.tf](main.tf)
    ```terraform
    resource "godaddy_domain_record" "our_site_record" {
        domain   = var.site_domain

        record {
            name = var.site_record
            type = "A"
            data = "192.168.1.2"
            ttl = 3600
        }
    }
    ```
    [variables.tf](variables.tf)
    ```terraform
    variable "site_record" {
        default = "cert-test-a"
    }

    variable "site_domain" {
        default = "guselietov.com"
    }
    ```
    [provider_godaddy.tf](provider_godaddy.tf)
    ```terraform
    provider "godaddy" { }    
    ```
- Init Terraform : 
    ```
    terraform init
    ```
- Run apply to use our initial config :
    ```bash
    $ terraform apply                

    An execution plan has been generated and is shown below.
    Resource actions are indicated with the following symbols:
    + create

    Terraform will perform the following actions:

    # godaddy_domain_record.our_site_record will be created
    + resource "godaddy_domain_record" "our_site_record" {
        + domain = "guselietov.com"
        + id     = (known after apply)

        + record {
            + data     = "192.168.1.2"
            + name     = "cert-test-a"
            + priority = 0
            + ttl      = 3600
            + type     = "A"
            }
        }

    Plan: 1 to add, 0 to change, 0 to destroy.

    Do you want to perform these actions?
    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.

    Enter a value: yes

    godaddy_domain_record.our_site_record: Creating...
    godaddy_domain_record.our_site_record: Creation complete after 5s [id=266392926]
    ```
- Check the record : 
    ```bash
    host cert-test-a.guselietov.com
    cert-test-a.guselietov.com has address 192.168.1.2
    ```
- Note, with the consqunet applys used mdule will try to remove some GoDaddy's default records, that can be solved with `import` feature, which unfortunately , again for this module is not stable yet. So, as workaround we can run first :
    ```
    terraform plan
    ```
    - See what recods are about to be changed/remove : 
    ```terraform
        - record {
            - data     = "@" -> null
            - name     = "www" -> null
            - priority = 0 -> null
            - ttl      = 3600 -> null
            - type     = "CNAME" -> null
            }
        - record {
            - data     = "_domainconnect.gd.domaincontrol.com" -> null
            - name     = "_domainconnect" -> null
            - priority = 0 -> null
            - ttl      = 3600 -> null
            - type     = "CNAME" -> null
            }
    ```
    - And convert that into our domain records description in [main.tf](main.tf) as follows : 
    ```terraform

    resource "godaddy_domain_record" "our_site_record" {
    domain = var.site_domain

    record {
        name = var.site_record
        type = "A"
        data = "192.168.1.2"
        ttl  = 3600
    }

    record {
        data     = "@"
        name     = "www"
        priority = 0
        ttl      = 3600
        type     = "CNAME"
    }

    record {
        data     = "_domainconnect.gd.domaincontrol.com"
        name     = "_domainconnect"
        priority = 0
        ttl      = 3600
        type     = "CNAME"
    }
    }
    ```
    > Note : Later we are going to move this chunk of code into separate file


# Technologies

1. **To download the content of this repository** you will need **git command-line tools**(recommended) or **Git UI Client**. To install official command-line Git tools please [find here instructions](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) for various operating systems. 
2. **For managing infrastructure** we using Terraform - open-source infrastructure as a code software tool created by HashiCorp. It enables users to define and provision a data center infrastructure using a high-level configuration language known as Hashicorp Configuration Language, or optionally JSON. More you encouraged to [learn here](https://www.terraform.io). 
3. **This project for virtualization** uses **AWS EC2** - Amazon Elastic Compute Cloud (Amazon EC2 for short) - a web service that provides secure, resizable compute capacity in the cloud. It is designed to make web-scale cloud computing easier for developers. You can read in details and create a free try-out account if you don't have one here :  [Amazon EC2 main page](https://aws.amazon.com/ec2/) 
4. **Nginx stands apart - as it will be downloaded and installed automatically during the provision.** Nginx is an open source HTTP Web server and reverse proxy server.In addition to offering HTTP server capabilities, Nginx can also operate as an IMAP/POP3 mail proxy server as well as function as a load balancer and HTTP cache server. You can get more information about it  - check [official website here](https://www.nginx.com)  
5. GoDaddy
6. Let'sEncrypt

# TODO
- [ ] register certificate
- [ ] create configuiration for deploying ec2-nginx machine
- [ ] tune configuraiton to include certificate
- [ ] update config

# DONE
- [x] export GoDaddy keys/challenge responce
- [x] create domain entry

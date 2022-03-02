# tf-move-state

# Repository for learning Terraform OSS
This repository has been created only for learning purposes to create 2 AWS instances in 2 different AWS regions

### Prerequisites

- [X] [Terraform](https://www.terraform.io/downloads)

## How to Use this Repo

- Clone this repository:
```shell
git clone git@github.com:dlavric/tf-move-state.git
```

- Go to the directory where the repo is stored:
```shell
cd tf-move-state/random_pet
```

- Run `terraform init`, to download any external dependency
```shell
terraform init
```


This is the output of initializing the Terraform code:
```shell
Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "random" (hashicorp/random) 3.1.0...
- Downloading plugin for provider "null" (hashicorp/null) 3.1.0...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.null: version = "~> 3.1"
* provider.random: version = "~> 3.1"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

- Apply the changes with Terraform
```shell
terraform apply
```

This is the output for applying the changes:
```shell
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # null_resource.hello will be created
  + resource "null_resource" "hello" {
      + id = (known after apply)
    }

  # random_pet.name will be created
  + resource "random_pet" "name" {
      + id        = (known after apply)
      + length    = 4
      + separator = "-"
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

random_pet.name: Creating...
random_pet.name: Creation complete after 0s [id=positively-lively-nice-killdeer]
null_resource.hello: Creating...
null_resource.hello: Provisioning with 'local-exec'...
null_resource.hello (local-exec): Executing: ["/bin/sh" "-c" "echo Hello positively-lively-nice-killdeer"]
null_resource.hello (local-exec): Hello positively-lively-nice-killdeer
null_resource.hello: Creation complete after 0s [id=3696642014406251110]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

- Create a folder for the module:
```shell
mkdir module_code
```

- Change the directory and create a `main.tf` file 
```shell
cd module_code

touch main.tf
```

- Paste the following code in the `main.tf` file that we have just created
```shell
resource "random_pet" "name" {
 length    = "4"
 separator = "-"
}

output "name" {
  value = random_pet.name.id
}
```

- Go back to the root module `tf-move-state/random_pet` and modify the `main.tf` root file
```shell
cd ..
```

```shell
module "random" {
  source = "./module_code"
}

resource "null_resource" "hello" {
  provisioner "local-exec" {
    command = "echo Hello ${module.random.name}"
  }
}
```

- In the root module `tf-move-state/random_pet` apply `terraform init` to initialize the module
```shell
terraform init

Initializing modules...
- random in module_code

Initializing the backend...

Initializing provider plugins...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.null: version = "~> 3.1"
* provider.random: version = "~> 3.1"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

- Check the changes that will be applied
```shell 
terraform plan

Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

random_pet.name: Refreshing state... [id=positively-lively-nice-killdeer]
null_resource.hello: Refreshing state... [id=3696642014406251110]

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
  - destroy

Terraform will perform the following actions:

  # random_pet.name will be destroyed
  - resource "random_pet" "name" {
      - id        = "positively-lively-nice-killdeer" -> null
      - length    = 4 -> null
      - separator = "-" -> null
    }

  # module.random.random_pet.name will be created
  + resource "random_pet" "name" {
      + id        = (known after apply)
      + length    = 4
      + separator = "-"
    }

Plan: 1 to add, 0 to change, 1 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

- We need to move the resource to the child module so there will be no changes
```shell
terraform state mv random_pet.name module.random.random_pet.name

Move "random_pet.name" to "module.random.random_pet.name"
Successfully moved 1 object(s).
```

- When applied, there will be no changes
```
terraform apply

module.random.random_pet.name: Refreshing state... [id=positively-lively-nice-killdeer]
null_resource.hello: Refreshing state... [id=3696642014406251110]

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

## Reference Documentation

- [Move a resource into a Module](https://www.terraform.io/cli/commands/state/mv#example-move-a-resource-into-a-module)

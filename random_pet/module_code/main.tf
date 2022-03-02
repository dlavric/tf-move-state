resource "random_pet" "name" {
 length    = "4"
 separator = "-"
}

output "name" {
  value = random_pet.name.id
}
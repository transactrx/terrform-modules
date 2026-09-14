module "task" {
  source = "../legacy"
  CPU = 256
  Memory = 512
  taskDefFamily = "compatibility"
  mainImageURL = "example.invalid/app:fixed"
  ContainerList = [{ name = "main", image = "$$MAIN_IMAGE$$", essential = true }]
}
output "task" { value = module.task }

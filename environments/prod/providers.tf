provider "aws" {
  region = var.home_region

  default_tags {
    tags = local.tags
  }
}

# One provider per region (OpenTofu >= 1.9 provider for_each).
# The provider set is a superset of the module set, so a region can be removed safely:
# move it from additional_regions to regions_pending_removal, apply, then delete it.
provider "aws" {
  alias    = "regional"
  for_each = local.provider_regions
  region   = each.value

  default_tags {
    tags = local.tags
  }
}

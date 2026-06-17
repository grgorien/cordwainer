dev:
	shopify theme dev --store $(SHOPIFY_FLAG_STORE) --theme $(SHOPIFY_THEME_DEV_ID)

push-dev:
	shopify theme push \
		--store $(SHOPIFY_FLAG_STORE) \
		--token $(SHOPIFY_CLI_THEME_TOKEN) \
		--theme $(SHOPIFY_THEME_DEV_ID)

push-demo:
	shopify theme push \
		--store $(SHOPIFY_FLAG_STORE) \
		--token $(SHOPIFY_CLI_THEME_TOKEN) \
		--theme $(SHOPIFY_THEME_ID) \
		--allow-live

local dec = {}

---Runs wealth decay on all provinces!
function dec.run(province)
		DATA.province_set_local_wealth(province,DATA.province_get_local_wealth(province) * 0.9999)
		DATA.province_set_trade_wealth(province,DATA.province_get_trade_wealth(province) * 0.9999)
end

return dec

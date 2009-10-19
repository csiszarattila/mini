# 
# Lokalizációs felülírás a magyar hónapnevekre
# 
class Date
	def to_format(format)
		hun_month_names = %w[zero Január Február Március Április Május Június] + 
			%w[Július Augusztus Szeptember Október November December]
		format.gsub!(/%B/,hun_month_names[self.month])
		self.strftime(format)
	end
end
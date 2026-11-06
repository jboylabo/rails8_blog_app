class Category < ActiveHash::Base
  self.data = [
    { id: 1, name: "技術" },
    { id: 2, name: "日記" }
  ]
end

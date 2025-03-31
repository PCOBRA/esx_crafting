Tổng quan chức năng
Script cho phép người chơi mở menu điều chế tại một vị trí cố định, chọn vật phẩm và số lượng để tạo ra sản phẩm, với các kiểm soát và thông báo phù hợp. Kết quả được ghi lại qua webhook Discord.

Các chức năng chính
Menu điều chế:
Vị trí: Người chơi phải đứng trong phạm vi 3 đơn vị từ tọa độ Config.CraftingLocation (vector3(2588.76, 4849.24, 34.96)).
Kích hoạt: Nhấn phím E khi gần bàn, hiển thị gợi ý [E] - Mở menu điều chế.
Danh sách vật phẩm: Hiển thị các công thức từ Config.CraftingRecipes (ví dụ: "Điều chế Bánh mì", "Điều chế Súng ngắn") với nguyên liệu cần thiết (ví dụ: "Nguyên liệu cho 1: Gạo tấp: 2 Nước: 1").
Chọn số lượng: Menu con hiện ra với các tùy chọn cố định: 1, 2, 5, 10.
Quy trình điều chế:
Đóng băng: Người chơi bị khóa di chuyển (FreezeEntityPosition) khi bắt đầu điều chế.
Thanh tiến độ: Hiển thị thanh tiến độ với nhãn "Đang điều chế [Tên vật phẩm] (x[Số lượng])" trong thời gian recipe.time * quantity (ví dụ: 10 giây cho 2 Bánh mì).
Animation: Phát hoạt ảnh PROP_HUMAN_BUM_BIN trong lúc điều chế.
Quản lý nguyên liệu và kho:
Kiểm tra nguyên liệu: Trước khi điều chế, script kiểm tra xem người chơi có đủ nguyên liệu trong kho không (dùng ox_inventory:Search).
Xóa nguyên liệu: Nếu đủ, xóa số lượng nguyên liệu cần thiết (ví dụ: 4 Gạo tấp, 2 Nước cho 2 Bánh mì).
Kiểm tra kho: Đảm bảo kho có đủ chỗ chứa sản phẩm (dùng ox_inventory:CanCarryItem).
Thêm vật phẩm: Sau khi hoàn thành, thêm sản phẩm vào kho (dùng ox_inventory:AddItem, ví dụ: 2 bread).
Thông báo:
Thành công: Khi hoàn thành, hiển thị thông báo "Bạn đã điều chế [Tên vật phẩm] (x[Số lượng])" ở vị trí center-left với loại success, kèm âm thanh PURCHASE.
Thất bại: Nếu thiếu nguyên liệu hoặc túi đầy:
Hiển thị thông báo "Bạn không đủ nguyên liệu: cần [Số lượng] [Tên vật phẩm], ..." hoặc "Túi đồ của bạn không đủ chỗ!" ở vị trí center-left với loại error.
Liệt kê đầy đủ các nguyên liệu thiếu (ví dụ: "cần 4 Gạo tấp, 2 Nước").
Không đủ cảnh sát: Nếu Config.RequiredCops > 0 và không đủ cảnh sát on duty, thông báo "Không đủ cảnh sát!" (hiện tại không áp dụng vì RequiredCops = 0).
Webhook Discord:
Thành công: Gửi tin nhắn đến Discord: "Người chơi [Tên] (ID: [ID]) đã điều chế thành công [Tên vật phẩm] x[Số lượng]."
Thất bại: Gửi tin nhắn với lý do, ví dụ: "Người chơi [Tên] (ID: [ID]) thất bại khi điều chế [Tên vật phẩm] x[Số lượng]: Bạn không đủ nguyên liệu: cần 4 Gạo tấp, 2 Nước."
Cấu hình: Dùng Config.WebhookURL để gửi qua HTTP request, màu xanh cho thành công (65280), đỏ cho thất bại (16711680).
Hạn chế và bảo vệ:
Số người điều chế: Giới hạn tối đa Config.MaxCraftingPlayers (3) người cùng lúc tại một bàn.
Xử lý thoát game: Nếu người chơi thoát trong lúc điều chế, script tự động xóa họ khỏi danh sách craftingPlayers, tránh lỗi hoặc thêm vật phẩm không mong muốn.

Các tính năng cụ thể
Công thức điều chế: Định nghĩa trong Config.CraftingRecipes:
bread: 2 Gạo tấp, 1 Nước, 5 giây cho 1 cái.
weapon_pistol: 10 Phế liệu kim loại, 5 Thuốc súng, 10 giây cho 1 cái.
Tọa độ cố định: vector3(2588.76, 4849.24, 34.96) gần Sandy Shores.
Thời gian tỷ lệ: Thời gian điều chế tăng theo số lượng (ví dụ: 2 Bánh mì = 10 giây).
Tích hợp ox_inventory: Quản lý nguyên liệu và sản phẩm hoàn toàn qua kho.

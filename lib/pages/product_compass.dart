import 'package:flutter/material.dart';
import '../services/image_service.dart';
import '../widgets/compass_background.dart';

class ProductCompassPage extends StatefulWidget {
  const ProductCompassPage({super.key});

  @override
  State<ProductCompassPage> createState() => _ProductCompassPageState();
}

class _ProductCompassPageState extends State<ProductCompassPage> {
  final _imageService = ImageService();

  void _showHomeAssistantDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF5E6D3), // 淺米色
                  Color(0xFFE8D5C4), // 中等米色
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // 標題欄
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFD17A3A), Color(0xFFB8956F)],
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Home Assistant Green',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // 內容區域
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 產品圖片
                        Center(
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: FutureBuilder<String>(
                                future: _imageService.getImageUrl('ha.png'),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Image.network(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    );
                                  } else if (snapshot.hasError) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(
                                          Icons.error,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  }
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF8B6914),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 硬體規格
                        _buildSection('一、硬體規格', [
                          '處理器：1.8 GHz 四核心 ARM Cortex-A55（Rockchip RK3566）',
                          '記憶體：4 GB LPDDR4 RAM',
                          '儲存空間：32 GB eMMC',
                          '網路連接：Gigabit Ethernet（RJ45）',
                          'USB 連接埠：USB 2.0 x2（可連接 Zigbee、Z-Wave、藍牙等擴充裝置）',
                          '機體設計：半透明藍綠色外殼格式化待接觸訊號',
                          '散熱系統：大型鋁製散熱片，無風扇靜音設計',
                        ]),

                        const SizedBox(height: 20),

                        // 軟體與相容性
                        _buildSection('二、軟體與相容性', [
                          '預載系統：Home Assistant OS（自動更新）',
                          '支援協議：Zigbee、Matter、Z-Wave、MQTT、Thread（需額外硬體支援）',
                          '相容性：支援 Apple HomeKit、Google Home、Amazon Alexa、Samsung SmartThings（部分功能需透過 Home Assistant Cloud）',
                          '擴充性：支援 Home Assistant Add-on Connect ZBT-1（Zigbee/Matter/Thread USB 模組）',
                          '具其他第三方 USB 裝置',
                        ]),

                        const SizedBox(height: 20),

                        // 使用方式
                        _buildSection('三、使用方式', [
                          '將電源與網路線插入主機',
                          '透過手機應用程式進行初始設定',
                          '系統將自動偵測並整合智慧裝置',
                        ]),

                        const SizedBox(height: 20),

                        // 產品特色
                        _buildSection('四、產品特色', [
                          '即插即用：無需額外設定，開機即用',
                          '高相容性：支援多種智慧裝置與雲端服務平台',
                          '隱私保護：資料在地端處理，保障使用者隱私',
                          '社群支持：擁有龐大的開發社群，持續提供更新與支援',
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B6914),
          ),
        ),
        const SizedBox(height: 12),
        ...items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(color: Color(0xFFD17A3A), fontSize: 16),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8B6914),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildProductList() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        children: [
          // 低壓燈具系列
          _buildCategorySection('低壓燈具系列', 'Low Voltage Lighting Series', [
            '單/雙色溫嵌燈 LED Recessed Lights',
            '單/雙色溫燈帶 LED Strip Lights',
            '單/雙色溫軌道燈 LED Track Lights',
            '幻彩嵌燈/燈帶 RGB LED Lights',
            '客製調光迴路 Custom Dimming Circuit',
            '調光迴路模組 Dimming Circuit Module',
          ]),

          const SizedBox(height: 32),

          // 開關控制系列
          _buildCategorySection('開關控制系列', 'Switch Control Series', [
            '無線調光開關 Wireless Dimmer Switch',
            '場景控制器 Scene Controller',
            '智能感應開關 Smart Motion Switch',
            '自定義調光模組 Custom Dimming Module',
          ]),

          const SizedBox(height: 32),

          // 復位開關系列
          _buildCategorySection('復位開關系列', 'Reset Switch Series', [
            '復古懷古系列 Retro Style Series',
            '進口雋永系列 Timeless Pieces Series',
            '進口靜奢系列 Quiet Luxury Series',
            '國際牌 Risna 系列 Panasonic Risna Series',
            '羅格朗 Artcur 系列 Legrand Artcur Series',
          ]),

          const SizedBox(height: 32),

          // 遙控器系列
          _buildCategorySection('遙控器系列', 'Remote Control Series', [
            '路創 遠端遙控器 Lutron Pico Remote',
            '路創 調光開關 Lutron Caseta',
            '觸控面板 Touch Panel',
            '語音控制模組 Voice Control Module',
          ]),

          const SizedBox(height: 32),

          // 物聯網設備系列
          _buildCategorySection('物聯網設備', 'IoT Devices', [
            'Home Assistant Green 智慧家庭中樞',
            'Zigbee 協調器 Zigbee Coordinator',
            'Matter 橋接器 Matter Bridge',
            'Z-Wave 控制器 Z-Wave Controller',
            'Thread 邊界路由器 Thread Border Router',
            'MQTT 閘道器 MQTT Gateway',
          ]),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    String title,
    String subtitle,
    List<String> products,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 大分類標題
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFFD17A3A), Color(0xFFB8956F)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 產品項目
        ...products
            .map(
              (product) => GestureDetector(
                onTap: () {
                  if (product.contains('Home Assistant')) {
                    _showHomeAssistantDialog();
                  }
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF5E6D3), // 淺米色
                        Color(0xFFE8D5C4), // 中等米色
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    product,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: product.contains('Home Assistant')
                          ? const Color(0xFFD17A3A) // 可點擊的顏色
                          : const Color(0xFF8B6914),
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD17A3A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: CompassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 主要可滑動內容區域
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // 主標題
                      const Text(
                        '調光',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B6914),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 副標題
                      const Text(
                        '開啟智慧新生活',
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFF8B6914),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 版本號
                      const Text(
                        '25th ver.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF8B6914),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // 產品列表標題
                      const Text(
                        '智能調光系統',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B6914),
                        ),
                      ),
                      const Text(
                        'Smart Lighting Control Systems',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFB8956F),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 產品列表
                      _buildProductList(),
                      const SizedBox(height: 40), // 底部額外空間
                    ],
                  ),
                ),
              ),
              // 固定在底部的 Logo
              Container(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    children: [
                      // Logo 圖標
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD17A3A),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 公司名稱
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '光悅',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD17A3A),
                            ),
                          ),
                          Text(
                            'COSELIO TECH.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8B6914),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

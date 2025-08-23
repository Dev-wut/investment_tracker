import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        DashboardUserInfo(),
        _DashboardPortfolio(),
        _DashboardOverviews(),
        _DashboardPortGrowth(),
        _DashboardMarkets(),
        _DashboardRecentTransaction(),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.columns});

  final Column columns;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(16.0), child: columns),
    );
  }
}

class DashboardUserInfo extends StatelessWidget {
  const DashboardUserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return _Card(
      columns: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Welcome back! Mr.Worawut Jeehia',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.supervised_user_circle_outlined, color: Colors.black,),
            ],
          )
        ],
      ),
    );
  }
}

class _DashboardPortfolio extends StatelessWidget {
  const _DashboardPortfolio();

  @override
  Widget build(BuildContext context) {
    return _Card(
      columns: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio value',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '฿128,450.69 THB',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -1.2,
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.keyboard_arrow_up_sharp,
                color: Color(0xFF1F8E5A),
                size: 25,
              ),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1B4C39),
                  ),
                  children: const [
                    TextSpan(
                      text: '24 ชม. : ',
                      style: TextStyle(
                        color: Color(0xFF1F8E5A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: '฿54,200.83',
                      style: TextStyle(color: Color(0xFF1F8E5A)),
                    ),
                    TextSpan(
                      text: ' +12.4%',
                      style: TextStyle(
                        color: Color(0xFF1F8E5A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.keyboard_arrow_down_sharp,
                color: Colors.red,
                size: 25,
              ),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1B4C39),
                  ),
                  children: const [
                    TextSpan(
                      text: '24 ชม. : ',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: '฿9311.83',
                      style: TextStyle(color: Colors.red),
                    ),
                    TextSpan(
                      text: ' -10.4%',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardPortGrowth extends StatelessWidget {
  const _DashboardPortGrowth();

  @override
  Widget build(BuildContext context) {
    return _Card(
      columns: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Portfolio growth',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
              ),
              const Spacer(),
              Text("1D", style: TextStyle(fontWeight: FontWeight.w400)),
              SizedBox(width: 4),
              Text("1W", style: TextStyle(fontWeight: FontWeight.w400)),
              SizedBox(width: 4),
              Text("1Y", style: TextStyle(fontWeight: FontWeight.w400)),
              SizedBox(width: 4),
              Text("ALL", style: TextStyle(fontWeight: FontWeight.w400)),
            ],
          ),
          SizedBox(height: 8),
          Placeholder(fallbackHeight: 300),
        ],
      ),
    );
  }
}

class _DashboardRecentTransaction extends StatelessWidget {
  const _DashboardRecentTransaction();

  @override
  Widget build(BuildContext context) {
    return _Card(
      columns: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
              ),
              Expanded(child: SizedBox.shrink()),
            ],
          ),
          SizedBox(height: 8),
          ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          radius: 14,
                          child: Icon(
                            Icons.trending_up,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: const <TextSpan>[
                                  TextSpan(
                                    text: 'BUY ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: 'TSLA'),
                                ],
                              ),
                            ),
                            Text(
                              "21 AUG 2025",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text("-฿1,500", style: TextStyle(color: Colors.red)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardOverviews extends StatelessWidget {
  const _DashboardOverviews();

  @override
  Widget build(BuildContext context) {
    return _Card(
        columns: Column(
          spacing: 8,
          children: [
            Row(
              children: [
                Text(
                  'ภาพรวม',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                  ),
                ),
                Expanded(child: SizedBox.shrink()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("กำไรในช่วงเวลาทั้งหมด"),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '+฿9,438.12',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F8E5A)
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.keyboard_arrow_up_sharp,
                          color: Color(0xFF1F8E5A),
                          size: 20,
                        ),
                        Text(
                          "25.87%",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F8E5A)
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Best Performer"),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          radius: 10,
                          child: Icon(
                            Icons.car_rental_outlined,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'TSLA',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.keyboard_arrow_up_sharp,
                          color: Color(0xFF1F8E5A),
                          size: 25,
                        ),
                        Text(
                          '29.45% +฿6,587.77',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F8E5A)
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Worst Performer"),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          radius: 10,
                          child: Icon(
                            Icons.rocket_launch_outlined,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'IONQ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.keyboard_arrow_down_sharp,
                          color: Colors.red,
                          size: 25,
                        ),
                        Text(
                          '29.45% +฿6,587.77',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
    );
  }
}

class _DashboardMarkets extends StatelessWidget {
  const _DashboardMarkets();

  @override
  Widget build(BuildContext context) {
    return _Card(
      columns: Column(
        spacing: 8,
        children: [
          Row(
            children: [
              Text(
                'ตลาดทั่วไป',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
              ),
              Expanded(child: SizedBox.shrink()),
            ],
          ),
          Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text("Bitcoin"),
                      Text("\$67,420"),
                      Text("+2.41%"),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text("ETH"),
                      Text("\$67,420"),
                      Text("+2.41%"),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text("S&P 500"),
                      Text("\$67,420"),
                      Text("+2.41%"),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text("NASDAQ"),
                      Text("\$67,420"),
                      Text("+2.41%"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



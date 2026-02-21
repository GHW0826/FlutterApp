import 'dart:async';
import '../models/list_item_model.dart';

/// List API (replace only this function when integrating with real backend).
Future<List<ListItemModel>> fetchProductList() async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return [
    const ListItemModel(id: 'p1', title: 'Product A', subtitle: 'PROD-001'),
    const ListItemModel(id: 'p2', title: 'Product B', subtitle: 'PROD-002'),
    const ListItemModel(id: 'p3', title: 'Product C', subtitle: 'PROD-003'),
  ];
}

Future<List<ListItemModel>> fetchTradeList() async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return [
    const ListItemModel(id: 't1', title: 'Trade #1001', subtitle: '2024-01-15'),
    const ListItemModel(id: 't2', title: 'Trade #1002', subtitle: '2024-01-16'),
    const ListItemModel(id: 't3', title: 'Trade #1003', subtitle: '2024-01-17'),
  ];
}

Future<List<ListItemModel>> fetchMarketInfoList() async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return [
    const ListItemModel(id: 'm1', title: 'KOSPI', subtitle: '2,500'),
    const ListItemModel(id: 'm2', title: 'KOSDAQ', subtitle: '850'),
    const ListItemModel(id: 'm3', title: 'USD/KRW', subtitle: '1,320'),
  ];
}

/// Theme list for Market Management (equity, commodity, fx, price_index, bond)
Future<List<ListItemModel>> fetchMarketThemeList(String themeId) async {
  await Future<void>.delayed(const Duration(milliseconds: 400));
  switch (themeId) {
    case 'equity':
      return [
        const ListItemModel(id: 'eq1', title: 'Samsung Electronics', subtitle: '005930'),
        const ListItemModel(id: 'eq2', title: 'SK Hynix', subtitle: '000660'),
        const ListItemModel(id: 'eq3', title: 'NAVER', subtitle: '035420'),
      ];
    case 'commodity':
      return [
        const ListItemModel(id: 'co1', title: 'WTI Crude', subtitle: 'CL'),
        const ListItemModel(id: 'co2', title: 'Gold', subtitle: 'GC'),
        const ListItemModel(id: 'co3', title: 'Silver', subtitle: 'SI'),
      ];
    case 'fx':
      return [
        const ListItemModel(id: 'fx1', title: 'USD/KRW', subtitle: '1,320'),
        const ListItemModel(id: 'fx2', title: 'EUR/KRW', subtitle: '1,450'),
        const ListItemModel(id: 'fx3', title: 'JPY/KRW', subtitle: '8.9'),
      ];
    case 'price_index':
      return [
        const ListItemModel(id: 'pi1', title: 'KOSPI', subtitle: '2,500'),
        const ListItemModel(id: 'pi2', title: 'KOSDAQ', subtitle: '850'),
        const ListItemModel(id: 'pi3', title: 'S&P 500', subtitle: '5,000'),
      ];
    case 'bond':
      return [
        const ListItemModel(id: 'bd1', title: 'Korean Treasury 3Y', subtitle: 'KR3YT'),
        const ListItemModel(id: 'bd2', title: 'Korean Treasury 10Y', subtitle: 'KR10YT'),
        const ListItemModel(id: 'bd3', title: 'US Treasury 10Y', subtitle: 'US10YT'),
      ];
    default:
      return [];
  }
}

Future<List<ListItemModel>> fetchUnderlyingList() async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return [
    const ListItemModel(id: 'u1', title: 'Samsung Electronics', subtitle: '005930'),
    const ListItemModel(id: 'u2', title: 'SK Hynix', subtitle: '000660'),
    const ListItemModel(id: 'u3', title: 'NAVER', subtitle: '035420'),
  ];
}

/// Theme list for Underlying (stock, commodity, rates_index, currency_pair, credit, bond)
Future<List<ListItemModel>> fetchUnderlyingThemeList(String themeId) async {
  await Future<void>.delayed(const Duration(milliseconds: 400));
  switch (themeId) {
    case 'stock':
      return [
        const ListItemModel(id: 'st1', title: 'Samsung Electronics', subtitle: '005930'),
        const ListItemModel(id: 'st2', title: 'SK Hynix', subtitle: '000660'),
        const ListItemModel(id: 'st3', title: 'NAVER', subtitle: '035420'),
      ];
    case 'commodity':
      return [
        const ListItemModel(id: 'uc1', title: 'WTI Crude', subtitle: 'CL'),
        const ListItemModel(id: 'uc2', title: 'Gold', subtitle: 'GC'),
        const ListItemModel(id: 'uc3', title: 'Brent', subtitle: 'BZ'),
      ];
    case 'rates_index':
      return [
        const ListItemModel(id: 'ri1', title: 'KOSPI', subtitle: '2,500'),
        const ListItemModel(id: 'ri2', title: 'S&P 500', subtitle: '5,000'),
        const ListItemModel(id: 'ri3', title: 'VIX', subtitle: '15'),
      ];
    case 'currency_pair':
      return [
        const ListItemModel(id: 'cp1', title: 'USD/KRW', subtitle: '1,320'),
        const ListItemModel(id: 'cp2', title: 'EUR/USD', subtitle: '1.08'),
        const ListItemModel(id: 'cp3', title: 'USD/JPY', subtitle: '149'),
      ];
    case 'credit':
      return [
        const ListItemModel(id: 'cr1', title: 'CDS Korea', subtitle: '50bp'),
        const ListItemModel(id: 'cr2', title: 'CDS US IG', subtitle: '80bp'),
        const ListItemModel(id: 'cr3', title: 'CDS US HY', subtitle: '350bp'),
      ];
    case 'bond':
      return [
        const ListItemModel(id: 'ub1', title: 'Korean Treasury 3Y', subtitle: 'KR3YT'),
        const ListItemModel(id: 'ub2', title: 'Korean Treasury 10Y', subtitle: 'KR10YT'),
        const ListItemModel(id: 'ub3', title: 'US Treasury 10Y', subtitle: 'US10YT'),
      ];
    default:
      return [];
  }
}

Future<List<ListItemModel>> fetchJobScheduleList() async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return [
    const ListItemModel(id: 'js1', title: 'Daily Position Sync', subtitle: '08:30'),
    const ListItemModel(id: 'js2', title: 'EOD Pricing Batch', subtitle: '17:10'),
    const ListItemModel(id: 'js3', title: 'Night Reconciliation', subtitle: '22:00'),
  ];
}

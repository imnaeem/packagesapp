import { NetworkRow, NetworkResponse } from '../types/network';
import { PackageRow, PackageResponse, ResourceData, AddonData } from '../types/package';
import { FeedbackRow, FeedbackResponse } from '../types/feedback';

export function formatNetwork(row: NetworkRow): NetworkResponse {
  return {
    id: row.id || '',
    name: row.name || '',
    slug: row.slug || '',
    slogan: row.slogan || '',
    logoUrl: row.logo_url || '',
    brandColor: row.brand_color || '#000000',
    isActive: Boolean(row.is_active),
    packageCount: Number(row.package_count || 0),
    createdAt: row.created_at || '',
  };
}

export function formatPackage(row: PackageRow): PackageResponse {
  let resources: ResourceData = {
    onNetMinutes: 0,
    offNetMinutes: 0,
    allNetMinutes: 0,
    sms: 0,
    dataMb: 0,
    dataGb: 0,
    dataTimeWindow: '24 Hours',
    dataPeakMb: 0,
    dataOffPeakMb: 0,
    socialMb: 0,
    socialApps: [],
  };

  if (row.resources_json) {
    try {
      const parsed = JSON.parse(row.resources_json);
      resources = {
        onNetMinutes: parsed.onNetMinutes ?? 0,
        offNetMinutes: parsed.offNetMinutes ?? 0,
        allNetMinutes: parsed.allNetMinutes ?? 0,
        sms: parsed.sms ?? 0,
        dataMb: parsed.dataMb ?? 0,
        dataGb: parsed.dataGb ?? 0,
        dataTimeWindow: parsed.dataTimeWindow ?? '24 Hours',
        dataPeakMb: parsed.dataPeakMb ?? 0,
        dataOffPeakMb: parsed.dataOffPeakMb ?? 0,
        socialMb: parsed.socialMb ?? 0,
        socialApps: Array.isArray(parsed.socialApps) ? parsed.socialApps : [],
      };
    } catch {
      // keep fallback
    }
  }

  let addons: AddonData[] = [];
  if (row.addons_json) {
    try {
      const parsed = JSON.parse(row.addons_json);
      if (Array.isArray(parsed)) {
        addons = parsed.map((a: any) => ({
          name: a.name || '',
          value: a.value || '',
          unit: a.unit || '',
        }));
      }
    } catch {
      // keep fallback
    }
  }

  let extraServices: string[] = [];
  if (row.extra_services_json) {
    try {
      const parsed = JSON.parse(row.extra_services_json);
      if (Array.isArray(parsed)) {
        extraServices = parsed.map(String);
      }
    } catch {
      // keep fallback
    }
  }

  let tags: string[] = [];
  if (row.tags_json) {
    try {
      const parsed = JSON.parse(row.tags_json);
      if (Array.isArray(parsed)) {
        tags = parsed.map(String);
      }
    } catch {
      // keep fallback
    }
  }

  return {
    id: row.id || '',
    networkId: row.network_id || '',
    name: row.name || '',
    category: row.category || 'hybrid',
    subCategory: row.sub_category || 'monthly',
    price: Number(row.price ?? 0),
    rechargeRequired: Number(row.recharge_required ?? 0),
    validityDays: Number(row.validity_days ?? 0),
    validityHours: Number(row.validity_hours ?? 0),
    validityType: row.validity_type || '',
    activationCode: row.activation_code || '',
    deactivationCode: row.deactivation_code || '',
    resources,
    addons,
    extraServices,
    details: row.details || '',
    tags,
    isActive: Boolean(row.is_active),
    isFeatured: Boolean(row.is_featured),
    isPopular: Boolean(row.is_popular),
    isSpecialOffer: Boolean(row.is_special_offer),
    createdAt: row.created_at || '',
    updatedAt: row.updated_at || '',
  };
}

export function formatFeedback(row: FeedbackRow): FeedbackResponse {
  return {
    id: row.id || '',
    userId: row.user_id || '',
    name: row.name || '',
    email: row.email || '',
    subject: row.subject || '',
    rating: Number(row.rating || 5),
    category: row.category || 'general',
    message: row.message || '',
    type: row.type || 'feedback',
    status: row.status || 'pending',
    deviceInfo: row.device_info || '',
    createdAt: row.created_at || '',
  };
}

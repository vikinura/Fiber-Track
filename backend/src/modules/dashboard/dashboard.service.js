import dashboardRepository from './dashboard.repository.js';

export class DashboardService {
  async getSummary(tenantId) {
    return await dashboardRepository.getSummary(tenantId);
  }

  async getByArea(tenantId) {
    return await dashboardRepository.getByArea(tenantId);
  }

  async getByVendor(tenantId) {
    return await dashboardRepository.getByVendor(tenantId);
  }
}

export default new DashboardService();

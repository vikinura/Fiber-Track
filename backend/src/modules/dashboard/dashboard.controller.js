import dashboardService from './dashboard.service.js';
import { sendSuccess } from '../../utils/response.js';

export class DashboardController {
  async getSummary(req, res, next) {
    try {
      const summary = await dashboardService.getSummary(req.auth.tenantId);
      return sendSuccess(res, summary);
    } catch (error) {
      next(error);
    }
  }

  async getByArea(req, res, next) {
    try {
      const areas = await dashboardService.getByArea(req.auth.tenantId);
      return sendSuccess(res, areas);
    } catch (error) {
      next(error);
    }
  }

  async getByVendor(req, res, next) {
    try {
      const vendors = await dashboardService.getByVendor(req.auth.tenantId);
      return sendSuccess(res, vendors);
    } catch (error) {
      next(error);
    }
  }
}

export default new DashboardController();

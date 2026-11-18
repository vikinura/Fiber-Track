import masterService from './master.service.js';
import { sendSuccess } from '../../utils/response.js';

export class MasterController {
  async getAreas(req, res, next) {
    try {
      const tenantId = req.auth.tenantId;
      const areas = await masterService.getAreas(tenantId);
      return sendSuccess(res, areas);
    } catch (error) {
      next(error);
    }
  }

  async createArea(req, res, next) {
    try {
      const tenantId = req.auth.tenantId;
      const area = await masterService.createArea(tenantId, req.body);
      return sendSuccess(res, area, 201);
    } catch (error) {
      next(error);
    }
  }

  async updateArea(req, res, next) {
    try {
      const tenantId = req.auth.tenantId;
      const id = req.params.id;
      const area = await masterService.updateArea(tenantId, id, req.body);
      return sendSuccess(res, area);
    } catch (error) {
      next(error);
    }
  }

  async deleteArea(req, res, next) {
    try {
      const tenantId = req.auth.tenantId;
      const id = req.params.id;
      await masterService.deleteArea(tenantId, id);
      return sendSuccess(res, { message: 'Area berhasil dihapus' });
    } catch (error) {
      next(error);
    }
  }

  async getOdps(req, res, next) {
    try {
      const tenantId = req.auth.tenantId;
      const areaId = req.query.area_id ? parseInt(req.query.area_id, 10) : null;
      const odps = await masterService.getOdps(tenantId, areaId);
      return sendSuccess(res, odps);
    } catch (error) {
      next(error);
    }
  }

  async getIssueTypes(req, res, next) {
    try {
      const tenantId = req.auth.tenantId;
      const issueTypes = await masterService.getIssueTypes(tenantId);
      return sendSuccess(res, issueTypes);
    } catch (error) {
      next(error);
    }
  }

  async getPriorities(req, res, next) {
    try {
      const tenantId = req.auth.tenantId;
      const priorities = await masterService.getPriorities(tenantId);
      return sendSuccess(res, priorities);
    } catch (error) {
      next(error);
    }
  }

  async getCustomers(req, res, next) {
    try {
      const tenantId = req.auth.tenantId;
      const search = req.query.search || req.query.q || '';
      const page = Math.max(1, parseInt(req.query.page, 10) || 1);
      const limit = Math.min(50, Math.max(1, parseInt(req.query.limit, 10) || 10));

      const result = await masterService.getCustomers(tenantId, { search, page, limit });
      return sendSuccess(res, result.data, 200, result.meta);
    } catch (error) {
      next(error);
    }
  }

  async createCustomer(req, res, next) {
    try {
      const tenantId = req.auth.tenantId;
      const customer = await masterService.createCustomer(tenantId, req.body);
      return sendSuccess(res, customer, 201);
    } catch (error) {
      next(error);
    }
  }

  async updateCustomer(req, res, next) {
    try {
      const tenantId = req.auth.tenantId;
      const id = req.params.id;
      const customer = await masterService.updateCustomer(tenantId, id, req.body);
      return sendSuccess(res, customer);
    } catch (error) {
      next(error);
    }
  }

  async deleteCustomer(req, res, next) {
    try {
      const tenantId = req.auth.tenantId;
      const id = req.params.id;
      await masterService.deleteCustomer(tenantId, id);
      return sendSuccess(res, { message: 'Pelanggan berhasil dihapus' });
    } catch (error) {
      next(error);
    }
  }

  async getVendors(req, res, next) {
    try {
      const tenantId = req.auth.tenantId;
      const vendors = await masterService.getActiveVendors(tenantId);
      return sendSuccess(res, vendors);
    } catch (error) {
      next(error);
    }
  }
}

export default new MasterController();

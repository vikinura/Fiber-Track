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
}

export default new MasterController();

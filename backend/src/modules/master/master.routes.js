import { Router } from 'express';
import masterController from './master.controller.js';
import { auth } from '../../middlewares/auth.js';
import { requireRole } from '../../middlewares/requireRole.js';
import { validate } from '../../middlewares/validate.js';
import {
  createAreaSchema,
  updateAreaSchema,
  deleteAreaSchema,
} from './areas.schema.js';
import {
  createCustomerSchema,
  updateCustomerSchema,
  deleteCustomerSchema,
} from './customers.schema.js';

const router = Router();

// Endpoint master hanya untuk role tenant_admin
router.use(auth);
router.use(requireRole('tenant_admin'));

router.get('/areas', masterController.getAreas);
router.post('/areas', validate(createAreaSchema), masterController.createArea);
router.put('/areas/:id', validate(updateAreaSchema), masterController.updateArea);
router.delete('/areas/:id', validate(deleteAreaSchema), masterController.deleteArea);

router.get('/odps', masterController.getOdps);
router.get('/issue-types', masterController.getIssueTypes);
router.get('/priorities', masterController.getPriorities);
router.get('/customers', masterController.getCustomers);
router.post('/customers', validate(createCustomerSchema), masterController.createCustomer);
router.put('/customers/:id', validate(updateCustomerSchema), masterController.updateCustomer);
router.delete('/customers/:id', validate(deleteCustomerSchema), masterController.deleteCustomer);

router.get('/vendors', masterController.getVendors);

export default router;
